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
