Wat
===

Simple library for doing time series analysis in Node.js. Much of the
functionality has been cloned from the time series module in Ruby's
statsample library: https://github.com/clbustos/statsample

Install
=======

Easy:

    npm install time-series

Usage
=====
        
Simple statistics:

    ts = new TimeSeries([1, 2, 3, 4]);

    ts.mean();  // => gives 2.5
    ts.sd();    // => gives around 1.291
    ts.var();   // => gives around 1.667

Moving averages:

    ts = new TimeSeries(_.range(30));

    // Default MA length is 10, gives 9 null observations at the start
    ts.ma();   // => [null, ..., null, 4.5, 5.5, 6.5, ..., 23.5, 24.5]

    // Different MA length
    ts.ma(5);  // => [null, ..., null, 2, 3, 4, 5, ...]

Exponential moving averages:

    ts = new TimeSeries(_.range(30));

    ts.ema();  // => [null, ..., null, 5.5, 6.5, 7.5, ...]
    ts.ema(5); // => [null, ..., null, 3, 4, 5, 6, ...]

Licence
=======

MIT
