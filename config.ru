#coding: utf-8
require_relative 'lib/engineer_calculator'
require 'erb'

class ShowEnv
  def initialize
    @test = Engineer::Calculator.new
  end


  def call(env)
    req = Rack::Request.new(env)
    @result = @test.calc(req.params["calc"])
    html = ERB.new(<<-EOF).result(binding)
      <html>
      <head>
      <!DOCTYPE html>
      <meta charset="utf-8">
      <!--[if lt IE 9]>
      <script src="/js/html5shiv-printshiv.min.js"></script>
      <![endif]-->
      </head>
      <body>
      <center style="font-size:20;position:sticky;top:0;background:#ffffff">
        <h2 style="color:#ffffff;background:#191970">Engineer Calculator / 技術者計算機</h2>
        <form method="POST">
          <input type="text" name="calc", style="width:50%;height:50px;font-size:20", value= <%= req.params["calc"] %> >
          <button type="submit" style="height:40px;font-size:15px">CALCULATE</button>
        </form>
        <h3><%= @result[2].to_s + " = " + @result[0].to_s + " " + @result[1].to_s if @result %></h3>
        <p>(使用可能な単位一覧 / List of available unit)</p>
      </center>
      <center style="padding-top:20pt">
      <% @test.variable_unit.each do |unit_name, unit_value| %>
        <table>
        <h3><%= unit_name %></h3>
        <% unit_value.each do |unit, value| %>
        <tr>
        <td><%= unit %></td>
        <td><%= value %></td>
        <tr>
        <% end %>
        </table>
      <% end %>
      </center>
      <p style="padding-top:20pt"></p>
      <center>
      <iframe src="https://rcm-fe.amazon-adsystem.com/e/cm?o=9&p=48&l=ez&f=ifr&linkID=e9f3e02bf960a9f2a71a66182b108202&t=eas01-22&tracking_id=eas01-22" width="728" height="90" scrolling="no" border="0" marginwidth="0" style="border:none;" frameborder="0"></iframe>
      </center>
      <footer style="color:#ffffff;background:#191970;text-align: center;"><a href="https://eastazy.work", style="color:#ffffff">Azy - Achieve Zero year - all right reserved<a></footer>
      </body>
      </html>
    EOF
    Rack::Response.new(html)

  end
end

run ShowEnv.new
