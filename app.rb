# frozen_string_literal: true

require "sinatra"
require "sinatra/reloader"
require "json"
require "securerandom"
require "pg"

before do
  @title = params[:title]
  @title = "non title" if @title == ""
  @body = params[:body]
end

class Memo
  @@connection = PG.connect(host: "localhost", user: "postgres", dbname: "memo_app", port: "5432")

  def self.all
    @@connection.exec("SELECT * FROM Memo;")
  end

  def self.find(id)
    @@connection.exec("SELECT * FROM Memo WHERE id = #{id};")
  end

  def self.write(title: title, body: body)
    @@connection.exec("INSERT INTO Memo (title, body) VALUES ('#{title}', '#{body}');")
  end

  def edit(id: id, title: title, body: body)
    @@connection.exec("UPDATE Memo SET title = '#{title}', body = '#{body}' WHERE id = '#{id}';")
  end

  def delete(id)
    @@connection.exec("DELETE FROM Memo WHERE id = #{id};")
  end
end

get "/" do
  @memos = Memo.all
  erb :index
end

get "/new" do
  erb :new
end

post "/new" do
  Memo.write(title: @title, body: @body)
  erb :new
  redirect "/"
end

get "/:id" do |id|
  @memo = Memo.find(id)
  erb :show
end

get "/:id/edit" do |id|
  @memo = Memo.find(id)
  erb :edit
end

put "/:id/edit" do |id|
  Memo.new.edit(id: id, title: @title, body: @body)
  redirect "/#{id}"
end

delete "/:id" do |id|
  Memo.new.delete(id)
  redirect "/"
end
