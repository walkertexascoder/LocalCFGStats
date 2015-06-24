### 2015-06-24

Deliver database structure for Competitions, Competitors, and Entries. 

Agree to build out standard deviations for Entries across all 2015 Regional division next. Tentatively move on to correlation between Open and Super Regional performances.

### 2015-06-17

Deliver ability to download Games, Regional, and Open results from 2011 at https://floelite-cfg-stats.herokuapp.com

Agree to build out the database so that we can store this information and do meanining work with it.

### 2015-06-10

Decide to use a Rails app as the base. It provides the necessary bits and can be freely hosted on Heroku to provide an easy interface to obtain data.

Add ability to gather basic data with HQ::Results [https://github.com/FloElite/CFGStats/blob/master/lib/hq/results.rb]. Some years still need some massaging.

### 2015-06-08

Agreed to initial work of:

1. Obtain data for
    1. Open, Regionals, and Games
    2. Men, Women, and Teams (no Masters?)
    3. Only get Open numbers for Regional qualifiers (originally discussed top 400 but I don't think they would be useful based on our conversaion thus far).
2. Provide code to obtain this data ad-hoc, without involvement of Don.
3. Provide data in CSV format so that it is consumable in any data processing software, e.g. Excel.
