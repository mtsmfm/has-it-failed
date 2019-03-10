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
    end
  end
end
