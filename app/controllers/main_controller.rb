# app/controllers/main_controller.rb
class MainController < ApplicationController
  def index
    #range = DateTime.now.beginning_of_day..DateTime.now.end_of_day
    range = DateTime.parse(params[:start_date]).beginning_of_day..DateTime.parse(params[:end_date]).end_of_day
    
    
    #start_time = DateTime.now.beginning_of_day
    #end_time = DateTime.now.end_of_day
    @collected = OrderPayment.select("COALESCE(sum(amount)) as amount").where(created_at: range).first.amount rescue 0
    #@collected = OrderPayment.find_by_sql("Select sum(amount) from order_payments where  order_entry_id = 6") rescue []
    #@collected = OrderPayment.where(created_at: range).sum(:amount)
    #@collected = OrderPayment.find_by_sql("COALESCE(sum(amount)) as amount where created_at between '#{params[:start_date]}'and '#{params[:end_date]}' ") rescue []

    # Get the selected report type from params
    report_type = params[:report_type]

    # Set the partial to be rendered based on report_type
    case report_type
    when "Daily Cash"
      @partial = "daily_summary_report"
    when "Cashier"
      @partial = "cashier_summary_report"
    when "Income"
      @partial = "income_summary_report"
    when "Census"
      @partial = "census_report"
    else
      @partial = "index" # Default to index if no valid report_type is selected
    end

    # Render the view (or respond to Turbo Stream if necessary)
    respond_to do |format|
      format.html # Render the full page if needed
      format.js   # Render JavaScript response if you are doing Turbo
    end
  end
  def income_summary
    case params[:report_duration]
    when 'Daily'
      @title = "Daily Income Summary for #{params[:start_date].to_date.strftime('%d %B, %Y')}"
      range = params[:start_date].to_date.beginning_of_day..params[:start_date].to_date.end_of_day
    when 'Weekly'
      @title = "Weekly Income Summary from #{params[:start_date].to_date.beginning_of_week.strftime('%d %B, %Y')} to
#{params[:start_date].to_date.end_of_week.strftime('%d %B, %Y')}"
      range = params[:start_date].to_date.beginning_of_week.beginning_of_day..params[:start_date].to_date.end_of_week.end_of_day
    when 'Monthly'
      @title = "Monthly Income Summary for #{params[:start_date].to_date.strftime('%B %Y')}"
      range = params[:start_date].to_date.beginning_of_month.beginning_of_day..params[:start_date].to_date.end_of_month.end_of_day
    when 'Range'
      @title = "Income Summary from #{params[:start_date].to_date.strftime('%d %B, %Y')} to #{params[:end_date].to_date.strftime('%d %B, %Y')}"
      range = params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day
    end

    data = Receipt.find_by_sql("Select * from receipts where payment_stamp between '#{range.first.strftime('%Y-%m-%d 00:00:00')}'
                                         and '#{range.last.strftime('%Y-%m-%d 23:59:59')}'")

    @records = view_context.income_summary(data)

  end

  def cashier_summary
    @user = User.find(params[:cashier]) rescue nil
    case params[:report_duration]
    when 'Daily'
      @title = "Daily income summary for #{params[:start_date].to_date.strftime('%d %B, %Y')} transactions  by #{@user.name}"
      range = params[:start_date].to_date.beginning_of_day..params[:start_date].to_date.end_of_day
    when 'Weekly'
      @title = "Weekly Income Summary from #{params[:start_date].to_date.beginning_of_week.strftime('%d %B, %Y')} to
                  #{params[:start_date].to_date.end_of_week.strftime('%d %B, %Y')}  transactions  by #{@user.name}"
      range = params[:start_date].to_date.beginning_of_week.beginning_of_day..params[:start_date].to_date.end_of_week.end_of_day
    when 'Monthly'
      @title = "Monthly Income Summary for #{params[:start_date].to_date.strftime('%B %Y')}  transactions  by #{@user.name}"
      range = params[:start_date].to_date.beginning_of_month.beginning_of_day..params[:start_date].to_date.end_of_month.end_of_day
    when 'Range'
      @title = "Income Summary from #{params[:start_date].to_date.strftime('%d %B, %Y')} to
                 #{params[:end_date].to_date.strftime('%d %B, %Y')}  transactions  by #{@user.name}"
      range = params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day
    end

    data = Receipt.find_by_sql("Select * from receipts where payment_stamp between '#{range.first.strftime('%Y-%m-%d 00:00:00')}'
                                         and '#{range.last.strftime('%Y-%m-%d 23:59:59')}' and cashier = #{params[:cashier]}")

    @records = view_context.income_summary(data)
  end

  def daily_cash_summary
    @headers = [%w[Consultation 0011 0071], %w[Book 0012 0072],%w[Drugs 0011 0071], %w[Laboratory 0012 0072],
                %w[Radiology 0011 0071], %w[Book 0012 0072],%w[Consultation 0011 0071], %w[Book 0012 0072],
                %w[Consultation 0011 0071], %w[Book 0012 0072],%w[Consultation 0011 0071], %w[Book 0012 0072]]

    shifts = view_context.work_shifts
    if params[:report_shift] == "Day"
      start_time = params[:start_date].to_date.strftime('%Y-%m-%d '+ shifts[params[:report_shift]].first)
      end_time = params[:start_date].to_date.strftime('%Y-%m-%d '+ shifts[params[:report_shift]].last)
    else
      start_time = params[:start_date].to_date.strftime('%Y-%m-%d '+ shifts[params[:report_shift]].first)
      end_time = (params[:start_date].to_date + 1.day).strftime('%Y-%m-%d '+ shifts[params[:report_shift]].last)
    end

    data = OrderPayment.find_by_sql("Select * from order_payments where created_at between '#{start_time}'
                                         and '#{end_time}' ") rescue []

    @shift = params[:report_shift]
    @start_date = start_time
    @end_date = end_time
    @records,@totals = cash_summary(data)
  end

  def print_daily_cash_summary

    data = OrderPayment.find_by_sql("Select * from order_payments where created_at between '#{params[:start_date]}'
                                         and '#{params[:end_date]}' ") rescue []

    date = params[:start_date].to_date.strftime('%d %B, %Y')
    data,totals = view_context.cash_summary(data)
    print_string = Misc.print_summary(data,totals,date, current_user.name, params[:shift])
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{params[:patient_id]}#{rand(10000)}.lbs", :disposition => "inline")
  end

  def census_report

    case params[:report_duration]
    when 'Daily'
      @title = "Daily Census Report for #{params[:start_date].to_date.strftime('%d %B, %Y')}"
      range = params[:start_date].to_date.beginning_of_day..params[:start_date].to_date.end_of_day
    when 'Weekly'
      @title = "Weekly Census Report from #{params[:start_date].to_date.beginning_of_week.strftime('%d %B, %Y')} to
                  #{params[:start_date].to_date.end_of_week.strftime('%d %B, %Y')}"
      range = params[:start_date].to_date.beginning_of_week.beginning_of_day..params[:start_date].to_date.end_of_week.end_of_day
    when 'Monthly'
      @title = "Monthly Census Report for #{params[:start_date].to_date.strftime('%B %Y')}"
      range = params[:start_date].to_date.beginning_of_month.beginning_of_day..params[:start_date].to_date.end_of_month.end_of_day
    when 'Range'
      @title = "Census Report from #{params[:start_date].to_date.strftime('%d %B, %Y')} to
                 #{params[:end_date].to_date.strftime('%d %B, %Y')}"
      range = params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day
    end

    new_registrations = Patient.select(:patient_id).where(date_created: range)
    new_ids = new_registrations.collect{|x| x.patient_id}
    returning_patients = Receipt.select(:receipt_number, :patient_id).where(payment_stamp: range).where.not(patient_id: new_ids).collect{|x| x.patient}
    @new_patients = view_context.census(new_registrations)
    @old_patients = view_context.census(returning_patients)
    @summary = {}
    @summary['M'] = @new_patients[:under_five][:M] + @new_patients[:under_twelve][:M] + @new_patients[:adult][:M]
    @summary['M'] += (@old_patients[:under_five][:M] + @old_patients[:under_twelve][:M] + @old_patients[:adult][:M])
    @summary['F'] = @new_patients[:under_five][:F] + @new_patients[:under_twelve][:F] + @new_patients[:adult][:F]
    @summary['F'] += (@old_patients[:under_five][:F] + @old_patients[:under_twelve][:F] + @old_patients[:adult][:F])
  end
end
