ss = require "simple-statistics"
_ = require "underscore"

###
# Class representing a series of data over time.
###
class TimeSeries
  constructor: (@data) ->

  # Get the length of the time series
  length: => @data.length

  # Get an element in the time series
  el: (n) => @data[n]

  ###
  # Operations on two time-series
  ###
  _operate: (other, _combiner) =>
    # Safe operations
    combiner = (a) ->
      if a[0] != null and a[1] != null
        _combiner a
      else
        null

    if other.constructor == TimeSeries
      new TimeSeries(_.map _.zip(@data, other.data), combiner)
    else if _.isArray other
      @_operate new TimeSeries(other), combiner
    else if _.isNumber other
      new TimeSeries(_.map @data, (n) -> combiner([n, other]))
    else
      throw "Unknown object on operation: #{other}"

  plus: (other) => @_operate other, (a) => a[0] + a[1]
  minus: (other) => @_operate other, (a) => a[0] - a[1]
  times: (other) => @_operate other, (a) => a[0] * a[1]
  div: (other) => @_operate other, (a) => a[0] / a[1]

  ###
  # Some standard statistical functions.
  ###

  # Calculate the mean of the series
  mean: => ss.mean @data
  average: => ss.mean @data
  # Calculate the standard deviation of the series
  sd: => ss.sample_standard_deviation @data
  # Calculate the variance of the series
  var: => ss.sample_variance @data

  ###
  # Time series specific data
  ###

  # Calculates a moving average of the series using the provided
  # lookback argument. The lookback defaults to 10 periods.
  #
  # Usage:
  #
  # ts = (1..100).map { rand }.to_ts
  # # => [0.69, 0.23, 0.44, 0.71, ...]
  #
  # # first 9 observations are nil
  # ts.ma # => [ ... nil, 0.484... , 0.445... , 0.513 ... , ... ]
  ma: (n = 10) =>
    return mean if n >= @data.length

    base = []

    for i in [1...n]
      base.push null

    for i in [0..(@data.length - n)]
      base.push _.reduce(@data.slice(i, i + n), (s, a) ->
        if a then s + a else s
      , 0.0) / n

    new TimeSeries(base)
  
  # Calculates an exponential moving average of the series using a
  # specified parameter. If wilder is false (the default) then the EMA
  # uses a smoothing value of 2 / (n + 1), if it is true then it uses the
  # Welles Wilder smoother of 1 / n.
  #
  # Warning for EMA usage: EMAs are unstable for small series, as they
  # use a lot more than n observations to calculate. The series is stable
  # if the size of the series is >= 3.45 * (n + 1)
  #
  # Usage:
  #
  # ts = Array(10).map(function () { return Math.random(); })
  # # => [0.69, 0.23, 0.44, 0.71, ...]
  #
  # # first 9 observations are nil
  # ts.ema() # => [ ... nil, 0.509... , 0.433..., ... ]
  ema: (n=10, wilder = false) =>
    # calculate an EMA of the series
    smoother = if wilder then 1.0 / n else 2.0 / (n + 1)

    # need to start everything from the first non-null observation
    start = 0
    for i in [0...@data.length]
      if @data[i]
        break
      else
        start++

    # first n - 1 observations are undefined
    base = []
    
    for i in [1...n]
      base.push null

    # nth observation is just a moving average
    last = _.reduce(@data.slice(start, start + n), (s, a) ->
      if a then s + a else s
    , 0.0) / n
    
    base.push last

    for i in [(start + n)...@data.length]
      current = @data[i] * smoother + (1.0 - smoother) * last
      base.push current
      last = current

    new TimeSeries base

  # Calculate a MACD (moving average convergence divergence) of the time series
  macd: (fast = 12, slow = 26, signal = 9) =>
    series = @ema(fast).minus(@ema(slow))
    [series, series.ema(signal)]

module.exports = TimeSeries
