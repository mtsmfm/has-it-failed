class ImportFailedJobsJob < ApplicationJob
  queue_as :default

  def perform(from:, to:)
    bigquery = Google::Cloud::Bigquery.new
    dataset = bigquery.dataset('rails_ci_result')

    data = dataset.query(<<~SQL)
      SELECT id as original_id, data, log, artifacts, created_at as original_created_at, build_number, build_data
      FROM `rails-ci-result.rails_ci_result.buildkite_jobs`
      WHERE "#{from.iso8601}" < created_at AND created_at < "#{to.iso8601}"
      AND JSON_EXTRACT_SCALAR(build_data, "$.state") = "failed"
      AND JSON_EXTRACT_SCALAR(build_data, "$.branch_name") = "master"
      AND JSON_EXTRACT_SCALAR(data, "$.passed") = "false"
      AND JSON_EXTRACT_SCALAR(data, "$.soft_failed") = "false"
      AND artifacts <> "[]"
    SQL

    FailedJob.insert_all!(data.map {|d| d.merge(created_at: Time.zone.now, updated_at: Time.zone.now) })
  end
end
