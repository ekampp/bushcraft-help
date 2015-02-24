class ArticlesController < ApplicationController
  self.resource_names = %i(articles)

  def show
    article.read! current_user
  end
end
