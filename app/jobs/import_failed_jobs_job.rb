class ImportFailedJobsJob < ApplicationJob
  queue_as :default

  def perform(from:, to:)
    bigquery = Google::Cloud::Bigquery.new
    dataset = bigquery.dataset('rails_travis_result')
    data = dataset.query(<<~SQL)
      CREATE TEMP FUNCTION extractCiResult (log STRING) RETURNS STRING LANGUAGE js AS
      """
        try {
          const railsCiResult = (TravisResultParser.parse(log)).find(
            command => command.includes('[Travis CI]')
          );
          return JSON.stringify(RailsCiParser.parse(railsCiResult));
        } catch {
          return 'error';
        }
      """
      OPTIONS
      (
        library=[
          "gs://rails-travis-result/parser/v0.1.0/rails_ci.js",
          "gs://rails-travis-result/parser/v0.1.0/travis_result.js"
        ]
      );

      CREATE TEMP FUNCTION JSON_ARRAY_LENGTH(str STRING) RETURNS NUMERIC LANGUAGE js AS
      """
        return JSON.parse(str).length
      """;

      SELECT * FROM(
        SELECT DISTINCT id, data, build_number, build_data, extractCiResult(log) as parse_result
        FROM `rails-travis-result.rails_travis_result.jobs` WHERE "#{from.iso8601}" < started_at AND started_at < "#{to.iso8601}"
      ) WHERE parse_result <> "error" and JSON_EXTRACT_SCALAR(data, "$.state") = "failed" and JSON_ARRAY_LENGTH(JSON_EXTRACT(parse_result, "$.failedTests")) > 0
    SQL

    data.each do |row|
      FailedJob.create!(
        original_id: row[:id],
        data: JSON.parse(row[:data]),
        build_number: row[:build_number],
        build_data: JSON.parse(row[:build_data]),
        parse_result: JSON.parse(row[:parse_result]),
      )
    end
  end
end
