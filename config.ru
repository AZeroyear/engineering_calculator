#coding: utf-8
require_relative 'eng_calc'

run ShowEnv.new

#
# run lambda {|env|
#   request = Rack::Request.new(env)
#
#   case request.path
#   when '/'
#     Rack::Response.new {|r| r.redirect("/hoge")}
#   when '/hoge'
#     name, sex = 'maeharin', 'man'
#
#     html = ERB.new(<<-EOF).result(binding)
#       <html>
#       <head><meta charset="utf-8"></head>
#       <body>
#       私の名前は<%= name %>。性別は<%= sex %>です。
#       </body>
#       </html>
#     EOF
#
#     Rack::Response.new(html)
#   else
#     Rack::Response.new("not found", 404)
#   end
# }



# require_relative 'root_map.rb'
# require 'rack/lobster'
#
# require_relative 'rack_urlmap'
#
# use NecoFilter
# run RootMap.new

# map '/simple' do
#   run EngCalc.new
# end
#
# map '/lobster' do
#   # Rackをインストールすると
#   # サンプルとして付いてくるアプリケーション
#   # ちょっと面白い
#   run Rack::Lobster.new
# end
