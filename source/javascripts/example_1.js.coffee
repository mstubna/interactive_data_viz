$ ->
  window.Example1 = new Example1

class Example1 
  
  constructor: ->
    @margin = {top: 20, right: 20, bottom: 30, left: 50}
    @width = 960 - @margin.left - @margin.right
    @height = 500 - @margin.top - @margin.bottom
    
    # the data
    @countries = window.data.countries
    @years = window.data.years

    @add_graph()    
    @add_year_slider()
    @add_axes()
    @add_tooltips()
    
    # initialize graph
    slider = $('#slider')
    slider.val('1960')
    slider.change()

  add_graph: ->
    # create the view
    @view = d3.select('#example').append('svg')
      .attr('width', @width + @margin.left + @margin.right)
      .attr('height', @height + @margin.top + @margin.bottom)
      .append('g')
      .attr('transform', "translate(#{@margin.left},#{@margin.top})")
    
    # add the bubbles
    @circles = @view
      .selectAll('circle')
      .data(@countries)
      .enter()
      .append('circle')
      .attr('class', '.circle')
    
    # define the scales
    @x_scale = d3.scale.linear().domain([10, 90]).range([0, @width])
    @y_scale = d3.scale.linear().domain([0.5, 10]).range([@height, 0])
    # scale r so that area is proportional to population
    @r_scale = d3.scale.linear().domain(@get_population_min_max().map (x) -> Math.sqrt(x)).range([1, 50])
  
  # calculates the min/max population for the data set
  get_population_min_max: ->
    all_data = @countries.reduce (prev, curr) ->
      prev.concat curr.population
    , []
    d3.extent(all_data)

  # html5 range inputs are supported by most browsers: http://caniuse.com/#feat=input-range
  add_year_slider: ->
    slider = $("<input id='slider' type='range' min='1960' max='2011'/>")
    curr_val = $("<span id='currentValue'></span>")
    $('#example').append [slider, $("<p id='note'>Year: </p>").append(curr_val)]

    slider.on 'change', =>
      val = slider.val()
      curr_val.html val
      @view_year @years.indexOf(Number(val))

  # transition the circles to the data at the given year
  view_year: (i) ->
    @circles
      .attr('cx', (d) => @x_scale(d.life_expectancy[i]))
      .attr('cy', (d) => @y_scale(d.fertility_rate[i]))
      .attr('r', (d) => @r_scale(Math.sqrt(d.population[i])))
  
  add_axes: ->
    @x_axis_view = @view.append('g')
      .attr('class', 'axis')
      .attr('transform', "translate(0,#{@height})")

    @y_axis_view = @view.append('g')
      .attr('class', 'axis')
    
    @x_axis = d3.svg.axis().scale(@x_scale).orient('bottom')
    @x_axis_view.call(@x_axis)

    @y_axis = d3.svg.axis().scale(@y_scale).orient('left')
    @y_axis_view.call(@y_axis)
      
    # axes labels
    $('#example').append [
      $("<div class='x_label label'>Life Expectancy (years)</div>")
      $("<div class='y_label label'>Fertility Rate</div>") ]

  # appends tooltips to the bars. Uses d3-tip.js
  # see http://bl.ocks.org/Caged/6476579
  add_tooltips: ->
    tip = d3.tip()
      .attr('class', 'd3-tip')
      .offset([-10, 0])
      .html((d) -> "<span>#{d.country_name}</span>")

    @view.call(tip)

    @circles
      .on('mouseover', tip.show)
      .on('mouseout', tip.hide)
      
      