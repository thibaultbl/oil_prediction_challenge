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
    """Function used to return percentile in
    pandas groupby().apply(
    
    Parameters
    ----
    n: percentile to return
    
    Return
    ----
    Percentile: float
    
    """
    def percentile_(x):
        return np.nanpercentile(x, n)
    percentile_.__name__ = 'percentile_%s' % n
    return percentile_

def new_name_if_not_id(x, prefix_name=None, ID="ID"):
    """Function to rename element if element different
    than ID (mostly used in list or Series)
        
        
    Parameters
    ----
    x: original name
    prefix_name: prefix to add at beggining of name
    ID: name of ID (element equals to ID will not be modified)
    
    Return
    ----
    New name if x != ID or unmodified x if ID: str
    """
    if x != ID:
        new_name = prefix_name + x
    else:
        new_name = x
    return(new_name)

def data_frame_as_Series(dataframe):
    """From a pandas DataFrame with one or multiple column,
    return a Series with column elements one after one
    
    Parameter
    ----
    dataframe: Pandas DataFrame as input
    
    Return
    ----
    Series with element of different column one after the other: list
    """
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

def describe_normal_outliers(pandas_series):
    outliers = (np.abs(pandas_series-pandas_series.mean())>(3*pandas_series.std()))
    return({"sum": outliers.sum(), "mean":outliers.mean()})

def get_useless_variable(estimator, x_train):
    variable_importance =\
    pd.concat([pd.DataFrame(x_train.columns),
               pd.DataFrame(estimator.feature_importances_)], axis=1)
    variable_importance.columns =["variable", "importance"]
    
    useless_variable = variable_importance.loc[variable_importance.importance == 0, :]
    return(useless_variable.variable)