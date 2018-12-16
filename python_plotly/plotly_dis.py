import plotly.plotly as py
import plotly.figure_factory as ff

import numpy as np
group_labels = ['GDP']
fig = ff.create_distplot([gdp], group_labels,bin_size=1000000)
fig.layout["title"]="GDP by county"
fig.layout["xaxis"]=dict(
        title='GDP($) log scale',
        type='log',
        autorange=True,
        titlefont=dict(
            family='Courier New, monospace',
            size=18,
            color='#7f7f7f',

        ))
fig.layout["yaxis"]=dict(
    title='probability',
     #type='log',
        #autorange=True,
    titlefont=dict(
        family='Courier New, monospace',
        size=18,
        color='#7f7f7f'
    ))
py.iplot(fig, filename='GDP by county')
