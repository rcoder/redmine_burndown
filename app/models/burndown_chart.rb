class BurndownChart
  attr_accessor :dates, :version, :start_date
  
  delegate :to_s, :to => :chart
  
  def initialize(version)
    self.version = version
    
    self.start_date = version.created_on.to_date
    end_date = version.effective_date.to_date
    self.dates = (start_date..end_date).inject([]) { |accum, date| accum << date }
  end
  
  def chart
    Gchart.line(
      :size => '750x400', 
      :data => data,
      :axis_with_labels => 'x,y',
      :axis_labels => [dates.map {|d| d.strftime("%m-%d") }],
      :custom => "chxr=1,0,#{sprint_data.max}",
      :line_colors => "DDDDDD,FF0000"
    )
  end
  
  def data
    [ideal_data, sprint_data]
  end
  
  def sprint_data
    @sprint_data ||= dates.map do |date|
      issues = all_issues.select {|issue| issue.created_on.to_date <= date }
      issues.inject(0) do |total_open_issues, issue|
        changes_before_date = issue.journals.find(:all, :conditions => ["created_on < :date", {:date => date}])

        if changes_before_date.nil?
            was_closed = !!(issue.status.is_closed?)
        else
            was_closed = !!(changes_before_date.detect {|change| change.new_status && change.new_status.is_closed? })
        end

        total_open_issues += 1 unless was_closed
        total_open_issues
      end
    end
  end
  
  def ideal_data
    [sprint_data.first, 0]
  end
  
  def all_issues
    version.fixed_issues.find(:all, :include => [{:journals => :details}, :relations_from, :relations_to])
  end
end
