class Organization::Public::Node::GroupsController < Cms::Controller::Public::Base
  def pre_dispatch
    @content = Organization::Content::Group.find_by_id(Page.current_node.content.id)
    return http_error(404) unless @content
    @more = (params[:filename_base] =~ /^more($|_)/i)
  end

  def index
    sys_group_codes = @content.root_sys_group.children.pluck(:code)
    @groups = @content.groups.public.where(sys_group_code: sys_group_codes)
  end

  def show
#TODO: Revert flatted groups
#    @group = @content.find_group_by_path_from_root(params[:group_names])
    @group = @content.groups.where(name: params[:group_names]).first
    return http_error(404) unless @group.try(:public?)

    Page.current_item = @group
    Page.title = @group.sys_group.name

    per_page = (@more ? 30 : @content.num_docs)

    settings = GpArticle::Content::Setting.arel_table
    article_contents = GpArticle::Content::Doc.joins(:settings)
                                              .where(settings[:name].eq('organization_content_group_id')
                                                                        .and(settings[:value].eq(@content.id)))
                                              .where(site_id: @content.site.id)
    @docs = if article_contents.empty?
              GpArticle::Doc.none
            else
#TODO: Revert flatted groups
#              sys_group_ids = @group.public_descendants.map{|g| g.sys_group.id }
#              find_public_docs_with_group_id(sys_group_ids)
              find_public_docs_with_group_id(@group.sys_group.id)
                .where(content_id: article_contents.pluck(:id))
                .order(@group.docs_order)
                .paginate(page: params[:page], per_page: per_page)
            end

    render 'more' if @more
  end

  private

  def find_public_docs_with_group_id(group_id)
    GpArticle::Doc.all_with_content_and_criteria(nil, group_id: group_id).mobile(::Page.mobile?).public
  end
end