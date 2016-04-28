require_relative 'test_helper'

class CategoriesTest < ActiveSupport::TestCase


  should 'logged user list categories' do
    login_api
    category = fast_create(Category, :environment_id => environment.id)
    get "/api/v1/categories/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json["categories"].map { |c| c["name"] }, category.name
  end

  should 'logged user get category by id' do
    login_api
    category = fast_create(Category, :environment_id => environment.id)
    get "/api/v1/categories/#{category.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal category.name, json["category"]["name"]
  end

  should 'logged user list parent and children when get category by id' do
    login_api
    parent = fast_create(Category, :environment_id => environment.id)
    child_1 = fast_create(Category, :environment_id => environment.id)
    child_2 = fast_create(Category, :environment_id => environment.id)

    category = fast_create(Category, :environment_id => environment.id)
    category.parent = parent
    category.children << child_1
    category.children << child_2
    category.save

    get "/api/v1/categories/#{category.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal({'id' => parent.id, 'name' => parent.name, 'slug' => parent.slug}, json['category']['parent'])
    assert_equivalent [child_1.id, child_2.id], json['category']['children'].map { |c| c['id'] }
  end

  should 'logged user include parent in categories list if params is true' do
    login_api
    parent_1 = fast_create(Category, :environment_id => environment.id) # parent_1 has no parent category
    child_1 = fast_create(Category, :environment_id => environment.id)
    child_2 = fast_create(Category, :environment_id => environment.id)

    parent_2 = fast_create(Category, :environment_id => environment.id)
    parent_2.parent = parent_1
    parent_2.children << child_1
    parent_2.children << child_2
    parent_2.save

    get "/api/v1/categories/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [nil], json['categories'].map { |c| c['parent'] }.uniq

    params[:include_parent] = true
    get "/api/v1/categories/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [parent_1.parent, parent_2.parent.id, child_1.parent.id, child_2.parent.id],
      json["categories"].map { |c| c['parent'] && c['parent']['id'] }
  end

  should 'logged user include children in categories list if params is true' do
    login_api
    category = fast_create(Category, :environment_id => environment.id)
    child_1 = fast_create(Category, :environment_id => environment.id)
    child_2 = fast_create(Category, :environment_id => environment.id)
    child_3 = fast_create(Category, :environment_id => environment.id)

    category.children << child_1
    category.children << child_2
    category.save

    child_1.children << child_3
    child_1.save

    get "/api/v1/categories/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [nil], json['categories'].map { |c| c['children'] }.uniq

    params[:include_children] = true
    get "/api/v1/categories/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [category.children.map(&:id).sort, child_1.children.map(&:id).sort, child_2.children.map(&:id).sort, child_3.children.map(&:id).sort],
      json["categories"].map{ |c| c['children'].map{ |child| child['id'] }.sort  }
  end

  expose_attributes = %w(id name full_name image display_color)

  expose_attributes.each do |attr|
    should "logged user expose category #{attr} attribute by default" do
      login_api
      category = fast_create(Category, :environment_id => environment.id)
      get "/api/v1/categories/?#{params.to_query}"
      json = JSON.parse(last_response.body)
     assert json["categories"].last.has_key?(attr)
    end
  end

  should 'anonymous list categories' do
    anonymous_setup
    category = fast_create(Category, :environment_id => environment.id)
    get "/api/v1/categories/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json["categories"].map { |c| c["name"] }, category.name
  end

  should 'anonymous get category by id' do
    anonymous_setup
    category = fast_create(Category, :environment_id => environment.id)
    get "/api/v1/categories/#{category.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal category.name, json["category"]["name"]
  end

  should 'anonymous list parent and children when get category by id' do
    anonymous_setup
    parent = fast_create(Category, :environment_id => environment.id)
    child_1 = fast_create(Category, :environment_id => environment.id)
    child_2 = fast_create(Category, :environment_id => environment.id)

    category = fast_create(Category, :environment_id => environment.id)
    category.parent = parent
    category.children << child_1
    category.children << child_2
    category.save

    get "/api/v1/categories/#{category.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal({'id' => parent.id, 'name' => parent.name, 'slug' => parent.slug}, json['category']['parent'])
    assert_equivalent [child_1.id, child_2.id], json['category']['children'].map { |c| c['id'] }
  end

  should 'anonymous include parent in categories list if params is true' do
    anonymous_setup
    parent_1 = fast_create(Category, :environment_id => environment.id) # parent_1 has no parent category
    child_1 = fast_create(Category, :environment_id => environment.id)
    child_2 = fast_create(Category, :environment_id => environment.id)

    parent_2 = fast_create(Category, :environment_id => environment.id)
    parent_2.parent = parent_1
    parent_2.children << child_1
    parent_2.children << child_2
    parent_2.save

    get "/api/v1/categories/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [nil], json['categories'].map { |c| c['parent'] }.uniq

    params[:include_parent] = true
    get "/api/v1/categories/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [parent_1.parent, parent_2.parent.id, child_1.parent.id, child_2.parent.id],
      json["categories"].map { |c| c['parent'] && c['parent']['id'] }
  end

  should 'anonymous include children in categories list if params is true' do
    anonymous_setup
    category = fast_create(Category, :environment_id => environment.id)
    child_1 = fast_create(Category, :environment_id => environment.id)
    child_2 = fast_create(Category, :environment_id => environment.id)
    child_3 = fast_create(Category, :environment_id => environment.id)

    category.children << child_1
    category.children << child_2
    category.save

    child_1.children << child_3
    child_1.save

    get "/api/v1/categories/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [nil], json['categories'].map { |c| c['children'] }.uniq

    params[:include_children] = true
    get "/api/v1/categories/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [category.children.map(&:id).sort, child_1.children.map(&:id).sort, child_2.children.map(&:id).sort, child_3.children.map(&:id).sort],
      json["categories"].map{ |c| c['children'].map{ |child| child['id'] }.sort  }
  end

  expose_attributes.each do |attr|
    should "anonymous expose category #{attr} attribute by default" do
      anonymous_setup
      category = fast_create(Category, :environment_id => environment.id)
      get "/api/v1/categories/?#{params.to_query}"
      json = JSON.parse(last_response.body)
     assert json["categories"].last.has_key?(attr)
    end
  end



end