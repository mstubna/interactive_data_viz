$ ->
  new Example3

class Example3 
  
  constructor: ->
    @margin = {top: 20, right: 20, bottom: 30, left: 50}
    @width = 960 - @margin.left - @margin.right
    @height = 500 - @margin.top - @margin.bottom
    
    @setup_data()
    @add_graph()
    @add_axes()
    @add_tooltips()
    @add_animate_buttons()
    
    # initialize the graph
    @show_horiz_table()

  setup_data: ->
    # just look at 2011 life_expectancy data  
    @data = window.data.countries.map (x) ->
      country_name: x.country_name
      life_expectancy: x.life_expectancy[51]
    @data.sort ((a,b) -> a.life_expectancy - b.life_expectancy)
    
    # d3s histogram function only calculates total bar heights, whereas we want to draw each datapoint separately
    # so calculate the coordinates of each data point when displayed in a histogram
    
    @buckets = [[45,50], [50,55], [55,60], [60,65], [65,70], [70,75], [75,80], [80,85]]

    # x coordinate is determined by the bucket the data point is in
    x_coords = @data.map (d) =>
      for bucket in @buckets
        break if d.life_expectancy >= bucket[0] and d.life_expectancy < bucket[1]
      (bucket[1]+bucket[0])/2
      
    # y coordinate is the bucket count
    y_coords = [1]
    for i in [1..x_coords.length-1]
      y_coords.push if x_coords[i] is x_coords[i-1] then y_coords[i-1]+1 else 1
    
    # assign the coordinates to each data point
    @data.map (d,i) ->
      d.histogram_x = x_coords[i]
      d.histogram_y = y_coords[i]

  add_graph: ->
    # create the view
    @view = d3.select('#example').append('svg')
      .attr('width', @width + @margin.left + @margin.right)
      .attr('height', @height + @margin.top + @margin.bottom)
      .append('g')
      .attr('transform', "translate(#{@margin.left},#{@margin.top})")
    
    # add the bars  
    @bars = @view
      .append('g')
      .selectAll('rect')
      .data(@data)
      .enter()
      .append('rect')      
  
  # displays the data in a horizontal table, each row being a country
  show_horiz_table: ->
    bar_width = 5
    x_domain = [44, 85]
    x_label = ''
    y_domain = [0, 600]
    y_label = 'Countries'
    
    @update_scales x_domain, y_domain

    @bars
      .transition()
      .duration(1000)
      .delay((d,i) -> 10*i)
      .attr('width', @x_scale(x_domain[1])-@x_scale(x_domain[0]))
      .attr('x', (d) => @x_scale(x_domain[0]))
      .attr('y', (d,i) => @y_scale(3*i))
      .attr('height', @height - @y_scale(3))
      .attr('stroke-width', 1)
      .attr('rx', 0)
      .attr('ry', 0)  
      
    @update_axes x_label, true, y_label, true
  
  # displays the data in a vertical table, each column being a country
  show_vert_table: ->
    bar_width = 5
    x_domain = [0, 600]
    x_label = 'Countries'
    y_domain = [0, 1]
    y_label = ''
    
    @update_scales x_domain, y_domain

    @bars
      .transition()
      .duration(1000)
      .delay((d,i) -> 10*i)
      .attr('width', 3)
      .attr('x', (d,i) => @x_scale(3*i))
      .attr('y', @y_scale(1))
      .attr('height', @y_scale(0))
      .attr('stroke-width', 1)
      .attr('rx', 0)
      .attr('ry', 0)
      
    @update_axes x_label, true, y_label, true
  
  # displays the data in a scatterplot
  show_scatterplot: ->
    bar_width = 20
    x_domain = [44, 85]
    x_label = 'Life Expectancy'
    y_domain = [0, 200]
    y_label = 'Countries'

    @update_scales x_domain, y_domain

    @bars
      .transition()
      .duration(1000)
      .delay((d,i) -> 10*i)
      .attr('width', bar_width)
      .attr('x', (d) => @x_scale(d.life_expectancy)-bar_width/2)
      .attr('y', (d,i) => @y_scale(i) - 20)
      .attr('height', @height - @y_scale(9))
      .attr('stroke-width', 1)
      .attr('rx', 10)
      .attr('ry', 10)

    @update_axes x_label, false, y_label, true

  # displays the data in a heatmap(?)
  show_heatmap: ->
    bar_width = 20
    x_domain = [44, 85]
    x_label = 'Life Expectancy'
    y_domain = [0, 1]
    y_label = 'Countries'

    @update_scales x_domain, y_domain

    @bars
      .transition()
      .duration(1000)
      .delay((d,i) -> 10*i)
      .attr('width', bar_width)
      .attr('x', (d) => @x_scale(d.life_expectancy)-bar_width/2)
      .attr('y', @y_scale(1))
      .attr('height', @y_scale(0))
      .attr('stroke-width', 0)
      .attr('rx', 0)
      .attr('ry', 0)

    @update_axes x_label, false, y_label, true

  # displays the data binned in a histogram
  show_histogram: ->
    bar_width = 90
    x_domain = [44, 85]
    x_tick_values = @buckets.map (b) -> (b[0]+b[1])/2
    x_tick_format = (x,i) =>
      bucket = @buckets[i]
      "#{bucket[0]}-#{bucket[1]-1}"
    x_label = 'Life Expectancy (years)'
    y_domain = [0, 50]
    y_label = 'Number of Countries'
      
    @update_scales x_domain, y_domain

    @bars
      .attr('class','histogram')
      .transition()
      .duration(1000)
      .delay((d,i) -> 10*i)
      .attr('width', bar_width)
      .attr('x', (d) => @x_scale(d.histogram_x)-bar_width/2)
      .attr('y', (d) => @y_scale(d.histogram_y))
      .attr('height', (d) => @height - @y_scale(1) )
      .attr('stroke-width', 1)
      .attr('rx', 0)
      .attr('ry', 0)
    
    @update_axes x_label, false, y_label, false, x_tick_values, x_tick_format
  
  update_scales: (x_domain, y_domain) ->
    @x_scale.domain x_domain
    @y_scale.domain y_domain
      
  update_axes: (x_label, x_axis_hidden, y_label, y_axis_hidden, x_tick_values, x_tick_format) ->
    # update axex views
    @x_axis_label.text x_label
    @y_axis_label.text y_label 
    @x_axis_view.classed 'hidden', x_axis_hidden
    @y_axis_view.classed 'hidden', y_axis_hidden

    # update x scale      
    if x_tick_values? and x_tick_format?
      @x_axis = d3.svg.axis().orient('bottom').scale(@x_scale).tickValues(x_tick_values).tickFormat(x_tick_format)
    else
      @x_axis = d3.svg.axis().orient('bottom').scale(@x_scale)
    # update y scale
    @y_axis = d3.svg.axis().orient('left').scale(@y_scale)
    
    # update axes
    @x_axis_view.call @x_axis
    @y_axis_view.call @y_axis

  # appends tooltips to the bars. Uses d3-tip.js
  # see http://bl.ocks.org/Caged/6476579
  add_tooltips: ->
    format = d3.format('0.1f')
    tip = d3.tip()
      .attr('class', 'd3-tip')
      .offset([-10, 0])
      .html((d) -> "<span>#{d.country_name}: #{format(d.life_expectancy)} yrs</span>")

    @view.call(tip)
    
    @bars
      .on('mouseover', tip.show)
      .on('mouseout', tip.hide)      
      
  add_axes: ->
    # scales
    @x_scale = d3.scale.linear().range([0, @width])
    @y_scale = d3.scale.linear().range([@height, 0])
    
    # axes views
    @x_axis_view = @view.append('g')
      .attr('class', 'axis')
      .attr('transform', "translate(0,#{@height})")
    @y_axis_view = @view.append('g')
      .attr('class', 'axis')
    
    # axes labels
    @x_axis_label = $("<div class='x_label label'></div>")
    @y_axis_label = $("<div class='y_label label'></div>")
    $('#example').append [@x_axis_label, @y_axis_label]  

  # button clicks transition the graph between its different representations
  add_animate_buttons: ->
    horiz_button = $("<button>Horizontal Table</button>")
    horiz_button.on 'click', => @show_horiz_table()
    
    vert_button = $("<button>Vertical Table</button>")
    vert_button.on 'click', => @show_vert_table()
    
    scatter_button = $("<button>Scatterplot</button>")
    scatter_button.on 'click', => @show_scatterplot()
    
    heatmap_button = $("<button>Heatmap</button>")
    heatmap_button.on 'click', => @show_heatmap()
    
    histogram_button = $("<button>Histogram</button>")
    histogram_button.on 'click', => @show_histogram()    

    $('#example').append($("<div id='button_container'></div").append([horiz_button, vert_button, scatter_button, heatmap_button, histogram_button]))
    
        




