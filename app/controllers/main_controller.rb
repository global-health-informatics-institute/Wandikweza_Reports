class MainController < ApplicationController
  def index
    @selected_report = params['report_type']
    case @selected_report
    when 'Daily Cash'
      daily_summary_report
    when 'Cashier'
      cashier_summary_report
    when 'Income'
      income_summary_report
    when 'Census'
      census_report
    end
  end

  def show

  end

  def daily_summary_report
  end

  def create
  end

  def destroy
  end
end
