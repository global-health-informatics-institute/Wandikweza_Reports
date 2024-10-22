class MainController < ApplicationController
  def index
    @selected_report = params['report_type']

    case @selected_report
    when 'Daily Cash'
      @report_content = daily_summary_report
      partial = 'daily_summary_report'
    when 'Cashier'
      @report_content = cashier_summary_report
      partial = 'cashier_summary_report'
    when 'Income'
      @report_content = income_summary_report
      partial = 'income_summary_report'
    when 'Census'
      @report_content = census_report
      partial = 'census_report'
    else
      @report_content = nil
      partial = 'default_report'
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("report_content", partial: partial, locals: { report: @report_content })
      end
      format.html
    end
  end

  private

  def daily_summary_report
    # Your logic for generating the daily summary report
  end

  def cashier_summary_report
    # Your logic for generating the cashier summary report
  end

  def income_summary_report
    # Your logic for generating the income summary report
  end

  def census_report
    # Your logic for generating the census report
  end
end
