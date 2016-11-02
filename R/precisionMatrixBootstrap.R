# R package for change-point detection in covariance structure
# Copyright (C) 2016 Valeriy Avanesov acopich@gmail.com 

getZ = function(theta, x) {
  theta %*% (x %*% t(x)) %*% theta
}

getZs = function(theta, X) {
  t(apply(X, 1, function(x) as.vector(getZ(theta,x))))
}

precisionMatrixBootstrapBasedCriticalLevel = function(stable, 
                                                      iterations, 
                                                      theta, 
                                                      N, 
                                                      windowSizes, 
                                                      parameterDifferenceNorm, 
                                                      distances2statistic,
                                                      Var) {
  means = colMeans(stable)
  stable = sweep(stable, 2, means, '-')
  Zs = getZs(theta, stable)
  
  SD = sqrt(Var)
  
  bootstrappedValues = sapply(1:iterations, function(iter) {
    bootstrapZ = Zs[sample(1:nrow(stable), N, replace = T), ]
    max(sapply(windowSizes, function(windowSize) {
      normalizedZ = sweep(bootstrapZ, 2, as.vector(SD/sqrt(windowSize)), '/')
      distances2statistic(slidingWindowsDifferenceOfMean(normalizedZ, 
                                                        windowSize, 
                                                        parameterDifferenceNorm))
    }))
  })
  
  unname(quantile(bootstrappedValues, probs = c(0.95)))
}





