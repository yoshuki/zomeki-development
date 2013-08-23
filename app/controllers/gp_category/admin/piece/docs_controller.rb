class GpCategory::Admin::Piece::DocsController < Cms::Admin::Piece::BaseController
  def update
    item_in_settings = (params[:item][:in_settings] || {})

    if (categories = params[:categories]).is_a?(Hash) && (layers = params[:layers]).is_a?(Hash)
      category_sets = []
      categories.each do |key, value|
        category_id = value.to_i
        next if category_sets.any? {|cs| cs[:category_id] == category_id }
        next if GpCategory::Category.where(id: category_id).empty?
        category_sets.push(category_id: category_id, layer: layers[key].to_s)
      end
      item_in_settings[:category_sets] = YAML.dump(category_sets)
    end

    if (gp_article_content_docs = params[:gp_article_content_docs]).is_a?(Array)
      item_in_settings[:gp_article_content_doc_ids] = YAML.dump(gp_article_content_docs.map{|d| d.to_i if d.present? }.compact.uniq)
    end

    params[:item][:in_settings] = item_in_settings

    super
  end
end
