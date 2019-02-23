#coding: utf-8
require_relative 'lib/engineer_calculator'
require 'erb'

class ShowEnv
  def initialize
    @eng_calc = Engineer::Calculator.new
  end

  def call(env)
    req = Rack::Request.new(env)
    @result = @eng_calc.calc(req.params["calc"])
    @alter = @eng_calc.alter
    @error = @eng_calc.error
    html = ERB.new(<<-EOF).result(binding)
      <html>
      <head>
      <!DOCTYPE html>
      <meta charset="utf-8">
      <!--[if lt IE 9]>
      <script src="/js/html5shiv-printshiv.min.js"></script>
      <![endif]-->
      <link rel=”shortcut icon” href= <%= "#{__dir__}/favicon.ico" %>>
      </head>
      <body>
      <center style="font-size:20;position:sticky;top:0;background:#ffffff">
        <h2 style="color:#ffffff;background:#191970">Engineer Calculator / 技術者計算機</h2>
        <form method="POST">
          <input type="text" name="calc", style="width:50%;height:50px;font-size:20", value= <%= req.params["calc"] %> >
          <button type="submit" style="height:40px;font-size:15px">CALCULATE</button>
        </form>
        <h3><%= @result[:convert_formula].to_s + " = " + @result[:value].to_s + " " + @result[:unit].to_s if @result %></h3>
      </center>
      <% unless @error.empty? %>
        <% @error.each do |err| %>
          <center><p><%= err %></p></center>
        <% end %>
      <% end %>
      <% if @alter %>
        <center style="padding-top:10pt">
          <h2> 単位換算結果 / Result of Convert Unit </h2>
          <% if @alter[:si_unit] %>
          <h3> (SI Unit) </h3>
            <% @alter[:si_unit].each do |unit_type, unit_name| %>
              <h3><%= unit_type %></h3>
              <table>
              <tr><td><h4><%= @result[:value].to_s if @result %></h4></td>
              <td><h4><%= unit_name %></h4></td></tr>
              <% @eng_calc.metric_prefix_unit.each do |prefix_name, val| %>
                <tr><td><%= sprintf("%.05g", @result[:value].to_f / val.to_f ) if @result %></td>
                <td><%= prefix_name + "  (" + unit_name + ")" %></td></tr>
              <% end %>
              </table>
            <% end %>
          <% end %>
          <% if @alter[:variable] %>
            <h3> (その他のUNIT / Variable Unit) </h3>
            <% @alter[:variable].each do |unit_type, unit_name| %>
              <h3><%= unit_type %></h3>
              <table>
              <% if unit_name %>
              <% unit_name.each do |unit, value| %>
                <tr><td><%= sprintf("%.05g", value) %></td>
                <td><%= unit %></td></tr>
              <% end %>
              <% end %>
              </table>
            <% end %>
          <% end %>
        </center>
      <% end %>

      <center style="padding-top:20pt">
      <p>(使用可能な単位一覧 / List of available unit)</p>
      <% @eng_calc.variable_unit.each do |unit_name, unit_value| %>
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
