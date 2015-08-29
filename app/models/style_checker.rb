# Filters files to reviewable subset.
# Builds style guide based on file extension.
# Delegates to style guide for line violations.
class StyleChecker
  def initialize(pull_request, build)
    @pull_request = pull_request
    @build = build
    @style_guides = {}
  end

  def review_files
    commit_files_to_check.each do |commit_file|
      style_guide(commit_file.filename).file_review(commit_file)
    end
  end

  private

  attr_reader :build, :pull_request, :style_guides

  def commit_files_to_check
    pull_request.commit_files.select do |file|
      file_style_guide = style_guide(file.filename)
      file_style_guide.enabled? && file_style_guide.file_included?(file)
    end
  end

  def style_guide(filename)
    style_guide_class = style_guide_class(filename)
    style_guides[style_guide_class] ||= style_guide_class.new(
      repo_config: config,
      build: build,
      repository_owner_name: pull_request.repository_owner_name,
    )
  end

  def style_guide_class(filename)
    StyleGuide.for(filename)
  end

  def config
    @config ||= RepoConfig.new(pull_request.head_commit)
  end
end
