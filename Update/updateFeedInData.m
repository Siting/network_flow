function[sourceFeed, sinkFeed] = updateFeedInData(SOURCE_LINK,SINK_LINK,page,nT, LINK, deltaTinSecond)

sourceFeed = updateAllSource(SOURCE_LINK,page,nT, LINK, deltaTinSecond);
sinkFeed = updateAllSink(SINK_LINK,page,nT, LINK, deltaTinSecond);