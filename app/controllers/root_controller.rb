class RootController < ApplicationController
  def index
    results = Rails.cache.fetch(:results, expires_in: 10.minutes) do
      FailedJob.select(:id, :original_id, :data, :artifacts, :build_number, :build_data).flat_map do |job|
        JSON.parse(job.artifacts).flat_map {|a| Nokogiri::XML.parse(a['body']).xpath("//failure | //error") }.flat_map do |failure_or_error|
          {
            job: job,
            filepath: failure_or_error.parent.parent['filepath'],
            message: failure_or_error.content,
            lineno: failure_or_error.parent['lineno'],
            classname: failure_or_error.parent['classname'],
            testname: failure_or_error.parent['name']
          }
        end
      end
    end

    @test_method = params[:q]
    if @test_method
      @failed_results = results.select {|r| r[:testname] == @test_method }
    else
      @failed_test_groups = results.group_by {|t| t.slice(:filepath, :classname, :testname) }.sort_by {|k, v| v.count }.reverse
    end
  end
end
