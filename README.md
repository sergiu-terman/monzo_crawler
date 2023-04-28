## Intro
This is a web crawler that can scrape a given website.

## Scope

### What it does
* Crawls a given website without leaving the boundaries of the website
* Stores the downloaded web pages on the filesystem
* Creates data models associated to the web pages and the links between them
* After it's done crawling, it can generate a graph artefact where you can explore the sitemap
### What it does not
This is a minimal crawler so the list of what it does not is rather long. But I'll try to narrow it down to the limited scope.

* It does not retry download failures. Once the download failed, it will be ignored.
* It cannot incrementally crawl the same website twice. You would to nuke all the data models associated to that website before starting again.
* It does not abide to `robots.txt` and other general "be a nice crawler" standards (bad crawler! bad!).
* It does not do rate limiting, although you could somewhat configure how many concurrent web fetches you can perform at the same time (no risk of DOS-ing the website).


## How to operate
For the purpose of the assignment the crawler is only scrapping monzo.com. Note that the hard-coded bit is minimal and if you wish to change the website you should only make a couple of adjustments in the `Runner::Main` class.

```ruby
def hard_coded_domain
  if Model::Domain.count == 0
    return Model::Domain.create(
      name: "etsy",
      domain_filter: "etsy.com",
      seed: "https://etsy.com",
    )
  end
  Model::Domain.find(name: "etsy")
end
```
#### Prerequisites
* Have docker installed (that's it)

#### Crawling
1. First build the docker image. Note that this can update your `Gemfile.lock` file. And that's okay. 

```bash
make build-docker
```

2. Run the crawler

```bash
make run
```

Note this command will run indefinitely. (I haven't built a proper top condition yet). Once you start to get enough messages of `No jobs found for...` you can kill the terminal window.

3. Generate the graph
```bash
make gen-graph
```

You can find the generated graph at `./storage/graph.gexf`

#### Additionally
1. You can open docker container of the project by running
```
docker exec
```
2. If you're familiar with a Rails like console, you can open  up a **REPL** where the project is loaded up. Here you can directly run ruby code. For instance you can run `Sequel` (**Sequel** is the ORM library used here on top of DB)

Start the REPL
```bash
make console
```

Run ruby code in the REPL 
```
> domain = Model::Domain.find(name: "monzo")
> domain.pages.count # (489) prints the number of monzo links it was able to find
> page = Model::Page.find(url: "https://monzo.com/i/business/")
> page.linked_to.count # (12) prints the number of monzo links found on the "business" page.
```

3. Nuke the data
```
make clean-all
```
This will nuke the database and the downloaded web pages as well.

**Extra**
You can check the `Makefile` to explore more of it.

## Technical details

The worker model:

![](https://i.imgur.com/cnKxPNG.png)
One caveat here is that for this project I'm using `sqlite`. Sqlite is known to be single threaded when performing writes. So in practice having large thread pools is causing the program to run slower and throw "Database busy" exceptions. I ended up parsing the monzo website with a single thread per pool (so much for this fancy model).

The main idea behind was ~~to show off~~ to reason about web fetching and parsing as 2 separate concepts that can be performed in isolation. And scaled accordingly. If we are to take the project beyond the local machine, we could start moving the worker queues to i.e. SQS for greater scalability. The `PageParser` and `PageDownloader` could be potentially run as 2 separate services etc.

I strongly suspect that if we are to move away from sqlite to, let's say, PostgreSQL then we could increase the thread pool and considerably speed up the crawling.

## Graph finds
Here's the Monzo sitemap in graph mode. It doesn't say much, but you could explore the graph yourself in gephi.

![](https://i.imgur.com/YIIuTSb.png)
#### Pages with most links
* https://monzo.com 22 (duh)
* https://monzo.com/legal/terms-and-conditions/ 16
* https://monzo.com/blog/2019/04/09/how-can-i-start-saving 13
* https://monzo.com/i/business/ 12
* https://monzo.com/i/supporting-customers 9
* https://monzo.com/blog/whats-new-in-monzo-october-2021/ 9
* https://monzo.com/i/money-worries/ 9
* https://monzo.com/blog/our-2021-diversity-and-inclusion-report 8
* https://monzo.com/blog/2017/04/05/banking-licence/ 8
* https://monzo.com/blog/2019/01/04/monzo-in-2019/ 8
* https://monzo.com/annual-report/2018/ 7
* https://monzo.com/blog/our-2020-diversity-and-inclusion-report 6
* https://monzo.com/legal/business-account-terms-and-conditions 6
* https://monzo.com/i/loans 6
* https://monzo.com/blog/2019/10/15/savings-plan 6
* https://monzo.com/fraud/ 5
* https://monzo.com/blog/cost-of-living-how-were-supporting 5
* https://monzo.com/blog/2015/10/30/we-are-ready 5
* https://monzo.com/blog/2017/05/11/api-update/ 5
* https://monzo.com/blog/2018/11/23/how-to-save-for-a-house-deposit/ 5
