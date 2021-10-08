# Tensorflow for R

## Installation

https://tensorflow.rstudio.com/installation/

First, install the tensorflow R package from GitHub as follows:

`install.packages("tensorflow")`

Then, use the `install_tensorflow()` function to install TensorFlow. Note that on Windows you need a working installation of Anaconda.

`library(tensorflow)`
`install_tensorflow()`

You can confirm that the installation succeeded with:

`library(tensorflow)`
`tf$constant("Hellow Tensorflow")`

_tf.Tensor(b'Hellow Tensorflow', shape=(), dtype=string)_

### Additiolnal packages
`install.packages(c("keras", "tfdatasets"))`
