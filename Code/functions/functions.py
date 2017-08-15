import pandas as pd
import numpy as np
import itertools as it
from sklearn.base import TransformerMixin, BaseEstimator
from sklearn.pipeline import Pipeline, FeatureUnion

def binary_if_positive(x):
    if x > 0:
        result = 1
    else:
        result = 0
    return(result)

def binary_if_0(x):
    if x == 0:
        result = 1
    else:
        result = 0
    return(result)

def binary_if_null(x):
    if pd.isnull(x):
        result = 1
    else:
        result = 0
    return(result)

def percentile(n):
    def percentile_(x):
        return np.nanpercentile(x, n)
    percentile_.__name__ = 'percentile_%s' % n
    return percentile_

def new_name_if_not_id(x, prefix_name=None, ID="ID"):
    if x != ID:
        new_name = prefix_name + x
    else:
        new_name = x
    return(new_name)

def data_frame_as_Series(dataframe):
    return(pd.Series(list(it.chain(*dataframe.values))))

class Replace0(BaseEstimator, TransformerMixin):
    def __init__(self, value=0):
        self.value=value
        
    def transform(self, X, *_):
        return X.replace(0, np.nan)
    
    def fit(self, *_):
        return self

class ImputerWithGivenValue(BaseEstimator, TransformerMixin):
    def __init__(self, value=0):
        self.value=value
        
    def transform(self, X, *_):
        return X.fillna(self.value)
    
    def fit(self, *_):
        return self
    
class ImputerWithMedianGroupby(BaseEstimator, TransformerMixin):
    def __init__(self, value=0):
        self.value=value
        
    def transform(self, X, *_):
        return X.fillna(self.value)
    
    def fit(self, *_):
        self.median_value = self.groupby(["country", "month"]).median()
        return self
