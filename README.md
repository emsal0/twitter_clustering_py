# Twitter Clustering Project

These are a collection of scripts that allow you to apply the DBSCAN algorithm to a person's "Followed" list on Twitter.

`get_followers.py` and `get_complete_follow_graph.py` are for collecting the Twitter data, and `process_data.jl` is for processing it into clusters.

## Usage

This project depends on the Python packages listed in `requirements.txt`. Install them system-wide or in a virtualenv.

The collection process takes 3 steps:

1. Run `get_followers.py` with three CLI arguments: the username of the account you wish to examine, your own Twitter username, and your Twitter password. Pipe the output of this into a file with a name of your choosing.
2. Run `get_complete_follow_graph.py` with three CLI arguments: the file where the output of step 1 is stored, your Twitter username, and your Twitter password. This collects the follow lists of everyone in your follow list and puts it in `data/` folder.
3. Run `process_data.jl` with one CLI argument: the name of a data folder (`data/` itself, or another folder if you've moved the output of step 2 somewhere else). This will output clusters.

## Current Issues

* Workflow needs improvement
* Selenium script unable to operate in PhantomJS, so it annoyingly opens Firefox browser windows.
