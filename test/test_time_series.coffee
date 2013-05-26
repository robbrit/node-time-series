TimeSeries = require "../time-series"
assert = require("chai").assert

describe "Tests time series functions", ->
  xiu = new TimeSeries [17.28, 17.45, 17.84, 17.74, 17.82, 17.85, 17.36, 17.3,
    17.56, 17.49, 17.46, 17.4, 17.03, 17.01, 16.86, 16.86, 16.56, 16.36, 16.66,
    16.77]

  it "should do basic statistics properly", (done) ->
    assert.closeTo 17.233, xiu.mean(), 0.0001, "calculate mean"
    assert.closeTo 0.4472, xiu.sd(), 0.0001, "calculate standard deviation"
    assert.closeTo 0.2, xiu.var(), 0.0001, "calculate variance"
    done()

  it "should add two time-series", (done) ->
    a = new TimeSeries [1, 2, 3, 4]
    b = new TimeSeries [4, 3, 32, 1]
    arr = [23, 5, 3, 9]

    assert.deepEqual [5, 5, 35, 5], a.plus(b).data, "Test with time series"
    assert.deepEqual [24, 7, 6, 13], a.plus(arr).data, "Test with array"
    assert.deepEqual [8, 9, 10, 11], a.plus(7).data, "Test with integer"
    done()

  it "should add two time-series, including null", (done) ->
    a = new TimeSeries [null, 2, 3, 4]
    b = new TimeSeries [4, 3, null, 1]
    arr = [23, 5, 3, null]

    assert.deepEqual [null, 5, null, 5], a.plus(b).data, "Test with time series"
    assert.deepEqual [null, 7, 6, null], a.plus(arr).data, "Test with array"
    assert.deepEqual [null, 9, 10, 11], a.plus(7).data, "Test with integer"
    done()

  it "should fail when trying to add things that don't make sense", (done) ->
    a = new TimeSeries [1, 2, 3, 4]

    assert.throws -> a.plus null
    assert.throws -> a.plus test: 5
    done()

  it "should subtract two time-series", (done) ->
    a = new TimeSeries [1, 2, 3, 4]
    b = new TimeSeries [4, 3, 32, 1]
    arr = [23, 5, 3, 9]

    assert.deepEqual [-3, -1, -29, 3], a.minus(b).data, "Test with time series"
    assert.deepEqual [-22, -3, 0, -5], a.minus(arr).data, "Test with array"
    assert.deepEqual [-6, -5, -4, -3], a.minus(7).data, "Test with integer"
    done()

  it "should multiply two time-series", (done) ->
    a = new TimeSeries [1, 2, 3, 4]
    b = new TimeSeries [4, 3, 32, 1]
    arr = [23, 5, 3, 9]

    assert.deepEqual [4, 6, 96, 4], a.times(b).data, "Test with time series"
    assert.deepEqual [23, 10, 9, 36], a.times(arr).data, "Test with array"
    assert.deepEqual [7, 14, 21, 28], a.times(7).data, "Test with integer"
    done()

  it "should divide two time-series", (done) ->
    a = new TimeSeries [1, 2, 5, 0]
    b = new TimeSeries [4, 2, 2, 1]
    arr = [2, 5, 5, 9]

    assert.deepEqual [0.25, 1, 2.5, 0], a.div(b).data, "Test with time series"
    assert.deepEqual [0.5, 0.4, 1, 0], a.div(arr).data, "Test with array"
    assert.deepEqual [0.5, 1, 2.5, 0], a.div(2).data, "Test with integer"
    done()

  it "should calculate MAs properly", (done) ->
    ma10 = xiu.ma()
    console.log ma10

    assert.closeTo ma10.el(19), 16.897, 0.001, "MA 10, spot 19"
    assert.closeTo ma10.el(15), 17.233, 0.001, "MA 10, spot 15"
    assert.closeTo ma10.el(10), 17.587, 0.001, "MA 10, spot 10"

    # test with a different lookback period
    ma5 = xiu.ma 5

    assert.closeTo ma5.el(19), 16.642, 0.001, "MA 5, spot 19"
    assert.closeTo ma5.el(10), 17.434, 0.001, "MA 5, spot 10"
    assert.closeTo ma5.el(5), 17.74, 0.001, "MA 5, spot 5"
    done()

  it "should calculate EMAs properly", (done) ->
    ema10 = xiu.ema()

    assert.closeTo ema10.el(19), 16.87187, 0.00001
    assert.closeTo ema10.el(15), 17.19187, 0.00001
    assert.closeTo ema10.el(10), 17.54918, 0.00001

    # test with a different lookback period
    ema5 = xiu.ema 5

    assert.closeTo ema5.el(19), 16.71299, 0.0001
    assert.closeTo ema5.el(10), 17.49079, 0.0001
    assert.closeTo ema5.el(5), 17.70067, 0.0001

    # test with a different smoother
    ema_w = xiu.ema 10, true

    assert.closeTo ema_w.el(19), 17.08044, 0.00001
    assert.closeTo ema_w.el(15), 17.33219, 0.00001
    assert.closeTo ema_w.el(10), 17.55810, 0.00001

    done()
