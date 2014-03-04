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
    
    # initialize the graph with a rank view
    @show_ranking()

  setup_data: ->
    # just look at 2011 life_expectancy data  
    @data = window.data.countries.map (x) ->
      country_name: x.country_name
      life_expectancy: x.life_expectancy[51]
    @data.sort ((a,b) -> a.life_expectancy - b.life_expectancy)
    
    # calculate the coordinates of each data point when to be displayed in a histogram
    
    buckets = [[45,50], [50,55], [55,60], [60,65], [65,70], [70,75], [75,80], [80,85]]

    # x coordinate is determined by the bucket the data point is in
    x_coords = @data.map (d) ->
      for bucket in buckets
        break if d.life_expectancy >= bucket[0] and d.life_expectancy <= bucket[1]
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
  
    # define default scales
    @x_scale = d3.scale.linear().domain([42, 87]).range([0, @width])
    @y_scale = d3.scale.linear().domain([0, 1]).range([@height, 0])
  
  # transitions the graph to a ranked display    
  show_ranking: ->
    bar_width = 15
    
    @y_scale.domain([0, 1])
    
    @bars
      .transition()
      .duration(1000)
      .delay((d,i) -> 20*i)
      .attr('class', 'ranking')
      .attr('width', bar_width)
      .attr('x', (d) => @x_scale(d.life_expectancy)-bar_width/2)
      .attr('y', @y_scale(1))
      .attr('height', @height - @y_scale(1))
      .attr('stroke-width', 0)
      
    $('.y_label').text('Countries')
    @y_axis_view.classed('hidden', true)
  
  # transitions the graph to a histogram
  show_histogram: ->
    bar_width = 90
    
    @y_scale.domain([0, 50])

    @bars
      .attr('class','histogram')
      .transition()
      .duration(1000)
      .delay((d,i) -> 20*i)
      .attr('width', bar_width)
      .attr('x', (d) => @x_scale(d.histogram_x)-bar_width/2)
      .attr('y', (d) => @y_scale(d.histogram_y))
      .attr('height', (d) => @height - @y_scale(1) )
      .attr('stroke-width', 1)
      
    $('.y_label').text('Number of Countries')
    @y_axis_view.classed('hidden', false)
    @y_axis_view.call(@y_axis)
  
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
    @x_axis_view = @view.append('g')
      .attr('class', 'axis')
      .attr('transform', "translate(0,#{@height})")

    @y_axis_view = @view.append('g')
      .attr('class', 'axis')
    
    @x_axis = d3.svg.axis().scale(@x_scale).orient('bottom')
      .tickValues([47.5,52.5,57.5,62.5,67.5,72.5,77.5,82.5])
      .tickFormat(d3.format("0.1f"))
    @x_axis_view.call(@x_axis)

    @y_axis = d3.svg.axis().scale(@y_scale).orient('left')
      
    # axes labels
    $('#example').append [
      $("<div class='x_label label'>Life Expectancy (years)</div>")
      $("<div class='y_label label'>Countries</div>") ]    
  
  # button clicks transition the graph  
  add_animate_buttons: ->
    histogram_button = $("<button>View Histogram</button>")
    histogram_button.on 'click', => @show_histogram()

    ranking_button = $("<button>View by Rank</button>")
    ranking_button.on 'click', => @show_ranking()

    $('#example').append($("<div id='button_container'></div").append([histogram_button, ranking_button]))
    
        




