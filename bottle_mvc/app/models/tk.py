#!/bin/env python
# coding:utf-8

import app.models.db as db
import app.models.pager as pager
import app.models.logger as logger
import re

class Tk:


    def list(self, page):

        define_page = 10
        start = (page - 1) * define_page

        result = {}

        sql = "select count(kijiId) as all_count from tkNewsXml where pubDate between '2015-01-01' and '2015-12-31'"
        db.live_con.execute(sql)
        result = db.live_con.fetchone()
        logger.logging.debug(result["all_count"])
        result["pagination"] = pager.Pagination(page, define_page, result["all_count"])

        sql = "select kijiId,title,pubDate from tkNewsXml where pubDate between '2015-01-01' and '2015-12-31' order by pubDate desc"
        sql += ' limit %s, %s'
        db.live_con.execute(sql, (start, define_page))
        res = db.live_con.fetchall()
        #kijis = []
        #for r in res:
        #    row={}
        #    row["title"]=r["title"].encode("utf-8")
        #    row["pubDate"]=r["pubDate"]
        #    row["kijiId"]=r["kijiId"].encode("utf-8")
        #    kijis.append(row)
        #    logger.logging.debug(type(r["title"]))
        #    logger.logging.debug(type(row["title"]))
        #    logger.logging.debug(r["title"])
        #    logger.logging.debug(row["title"])
        result["kijis"]=res
        #logger.logging.debug(result["kijis"])

        return result


    def detail(self, id):

        sql = "select kijiId,title,pubDate,content from tkNewsXml where kijiId =%s"
        db.live_con.execute(sql,(str(id),))
        result=db.live_con.fetchone()
        content=result["content"]
        content=re.sub("\<.*?\>","",content)
        content=re.sub("&.*?;","",content)
        result["content"]=content
        return result


