# use_of_cleanpaths

In general, we use cleanpaths (no leading `./`). We make this explicit because `Pathname.new('./foo') != Pathname.new('/foo')`, so the explicit distinction is important for clients to be able to rely on the public API.

Also, Packwerk itself seems to use clean pathnames throughout, so it is best to stay conceptually consistent.
