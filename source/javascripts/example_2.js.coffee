$ ->
  new Example2

class Example2 
  
  constructor: ->
    @data = window.data
    @activity_names = @data[0].map (x) -> x.name

    @margin = {top: 20, right: 20, bottom: 30, left: 50}
    @width = 960 - @margin.left - @margin.right
    @height = 500 - @margin.top - @margin.bottom
    
    @create_graph()
    @add_axes()
    @add_legend()
    @add_activity_selector()
    @add_year_selector()
    
  create_graph: ->
    # create the view
    @view = d3.select('#example').append('svg')
      .attr('width', @width + @margin.left + @margin.right)
      .attr('height', @height + @margin.top + @margin.bottom)
      .append('g')
      .attr('transform', "translate(#{@margin.left},#{@margin.top})")

    # define scales
    @x_scale = d3.scale.linear().domain([0, 23]).range([0, @width])
    @y_scale = d3.scale.linear().domain([0, 100]).range([@height, 0])
    @color_scale = d3.scale.category20().domain(@activity_names)
    
    # area
    @area = d3.svg.area()
      .x( (d) => @x_scale(d.x) )
      .y0( (d) => @y_scale(d.y0) )
      .y1( (d) => @y_scale(d.y0 + d.y) )
    
    # use the d3 stack function to map the data into form needed for stacked graph
    @stack = d3.layout.stack().values( (d) -> d.values)
    data = @stack(@data[0].map (x) ->
      name: x.name
      values: x.values.map (d,i) -> {x: i, y: d} )
    
    # draw the areas
    @view.selectAll('path')
      .data(data)
      .enter().append('path')
      .attr('d', (d) => @area(d.values))
      .style('fill', (d) => @color_scale(d.name))
    
  add_axes: ->
    x_axis = d3.svg.axis().scale(@x_scale).orient('bottom')
    y_axis = d3.svg.axis().scale(@y_scale).orient('left')
    
    @view.append('g')
      .attr('class', 'axis')
      .attr('transform', "translate(0,#{@height})")
      .call(x_axis)

    @view.append('g')
      .attr('class', 'axis')
      .call(y_axis)
    
    # axes labels
    $('#example').append [
      $("<div class='x_label label'>Time of Day</div>")
      $("<div class='y_label label'>Percentage of Total Time</div>") ]

  add_legend: ->
    @legend_view = d3.select('#example').append('svg')
      .attr('width', @width + @margin.left + @margin.right)
      .attr('height', 700 + @margin.top + @margin.bottom)
      .append('g')
      .attr('transform', "translate(#{@margin.left},#{@margin.top})")
    
    legend = @legend_view.selectAll('.legend')
      .data(@activity_names.slice().reverse())
      .enter().append('g')
      .attr('class', 'legend')
      .attr('transform', (d,i) -> "translate(0,#{i*20})")

    legend.append('rect')
      .attr('width', 18)
      .attr('height', 18)
      .style('fill', @color_scale);

    legend.append('text')
      .attr('x', 24)
      .attr('y', 9)
      .attr('dy', '.35em')
      .text((d) -> d )
  
  add_activity_selector: ->
    @activity_select = $("<select id='activity_selector'></select>")
    @activity_select.append $("<option value='All'>All</option>")
    @activity_names.map (x) => @activity_select.append $("<option>#{x}</option>")
    $('#example').append @activity_select

    @activity_select.on 'change', => @transition()
  
  add_year_selector: ->
    @year_select = $("<select id='year_selector'></select>")
    @year_select.append [$("<option>2003-2007</option>"), $("<option>2007-2011</option>")]
    $('#example').append @year_select

    @year_select.on 'change', => @transition()
  
  transition: ->
    data = @data[@year_select.prop('selectedIndex')]
    index = @activity_select.prop('selectedIndex')
    
    data = @stack(data.map (x,i) ->
      name: x.name
      values: x.values.map (d,j) -> {x: j, y: if index is 0 or index-1 is i then d else 0} )
    d3.selectAll('path').data(data).transition().duration(1000).attr('d', (d) => @area(d.values))
      
      
      
      