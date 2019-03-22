class RootController < ApplicationController
  def index
    @test_method = params[:q]
    if @test_method
      @failed_jobs = FailedJob.where("parse_result->'failedTests' @> ?", [
        {
          results: [{
            method: @test_method
          }]
        }
      ].to_json)
    else
      results = FailedJob.pluck(Arel.sql("jsonb_array_elements(parse_result -> 'failedTests')->'results'")).flatten
      @most_failed_tests = results.select {|r| r.key?('method') && r.key?('testClass') }.group_by {|r| r.slice('method', 'testClass') }.transform_values(&:count).sort_by(&:last).reverse
    end
  end
end
