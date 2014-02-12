var cluster = require("cluster");
var numCPUs = process.env.FORK || require('os').cpus().length;

env = process.env.NODE_ENV || 'development'

boot = function(){
  require("coffee-script");
  if(env=='development') require('coffee-trace');
  require('http').globalAgent.maxSockets = Infinity // Infinity concurrent per host
  require('./app');  
}

if (cluster.isMaster && env != 'development') {
  // Fork workers.
  for (var i = 0; i < numCPUs; i++) {
    cluster.fork();
  }

  cluster.on("death", function(worker) {
    console.log("worker " + worker.pid + " died");
    cluster.fork(); 
  });
  cluster.on('exit', function(worker, code, signal) {
    console.log("worker " + worker.pid + " died");
    cluster.fork();
  });
} else {
  boot();
}