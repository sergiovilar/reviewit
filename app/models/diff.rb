  # Source can be :git or :interdiff
  def initialize(diff, source: :git)
    @file_metadata_reader = source == :git ? :start_reading_git_file_metadata : :start_reading_interdiff_file_metadata
    attr_accessor :interdiff_tag
      next if send(@file_metadata_reader, line)
      @state = :state_reading_subject
    @state = :state_reading_commit_message if line.blank?
    @state = :state_reading_commit_message if line.blank?
  def start_reading_git_file_metadata(line)
    return false unless line.start_with?('diff --git ')
    @state = :state_reading_file_metadata
  end

  def start_reading_interdiff_file_metadata(line)
    new_file_line = line =~ /^(diff -u|---|\+\+\+)/
    interdiff_tag = line =~ /^(reverted|unchanged|only in patch2|only in patch1)/
    return false if !new_file_line && !interdiff_tag

    new_file_found = !interdiff_tag && (line.start_with?('diff') || @next_interdiff_tag)

    if interdiff_tag
      @next_interdiff_tag = $1.capitalize
    elsif new_file_found
      if line.start_with?('diff')
        line =~ %r{^diff -u .?/(.*) .?/(.*)}
        file_name = $2 == '/dev/null' ? $1 : $2
      else
        line =~ %r{^... ./(.*)}
        return true if $1.nil?
        file_name ||= $1
      end
      @file = File.new
      @file.name = file_name
      @file.interdiff_tag = @next_interdiff_tag
      @next_interdiff_tag = nil
      @files[@file.name] = @file

      if line.start_with?('+++')
        @file.index = 0 # Don't care about index on interdiffs
        @state =  :state_reading_file_changes
      else
        @state = :state_reading_file_metadata
      end
    end
      @state = :state_reading_file_changes
      @state = :state_reading_file_changes
      nil
    if line == "-- \n"
      @state = :state_idle
    else
      line.chop! if line.end_with?("\n")
      @file.changes << line
    end