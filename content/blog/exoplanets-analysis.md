---
author: "Pierre Zemb"
date: 2017-09-18
title: "The quest to discover exoplanets with Warp10 and Tensorflow"
best: true
tags: ["warp10","time series","exoplanet","tensorflow"]
draft: true
description: "The quest to discover exoplanets with Warp10 and Tensorflow"
---

My passion for programming was kind of late, I typed my first line of code at my engineering school. It then became a **passion**, an hobby, something I'm willing to do at work, on my free-time, at night or the week-end. But before meeting with C and other languages, I had another passion: **astronomy**. Yes, I was that kind of boy who was **looking at the sky** with a telescope that was tallest than himself. Every summer, I was partipating at the **[Nuit des Etoiles](https://www.afastronomie.fr/les-nuits-des-etoiles)**, a **global french event** organized by numerous clubs of amateur astronomers who offer several hundreds (between 300 and 500 depending on the year) of free animation sites for the general public.

![image](/img/exoplanet-analysis/aabi.png)

<center>As you can see below, I was **kind of young at the time**!</center>


But the sad truth is that I didn't do any astronomy during my studies. But now, **I want to get back to it and look at the sky again**. But there was two obstacles:

* The price of equipements
* The local weather

**I was looking something that would unit my two passions: computer and astronomy**. So I started googling:

![image](/img/exoplanet-analysis/googling.png)

I found amazing project with Raspberry Pis, but I didn't find something that would motivate me over the time. So I started typing over keywords, more work-related, such as *time series* or *analytics*. I found many papers related to astrophysics, but there was two keywords that were coming back: **exoplanet detection** and **light curves**.

# What is an exoplanet and how to detect it?

Let's quote our good old friend **[Wikipedia](https://en.wikipedia.org/wiki/Exoplanet)**:

> An exoplanet or extrasolar planet is a planet outside of our solar system that orbits a star. 

do you have any idea of the number of exoplanets that have been discovered? **3,509 confirmed planets** as of 08/24/2017. I was amazed by the number of exoplanets already found. I started digging on the **[detection methods](https://en.wikipedia.org/wiki/Methods_of_detecting_exoplanets)**. Turns out there is one method heavily used, called **the transit method**. It's like a eclipse: as the planet is passing in front of the star, the photometry is varying during the transit, as shown below:

<center>
{{< tweet 898245628022497280 >}}
</center>

To recap, exoplanet detection using the transit method are in reality **time series analysis problem**. As I'm starting to be familiar with that type of analytics thanks to my current work at OVH in **[Metrics Data Platform](https://www.ovh.com/fr/data-platforms/metrics/)**, I wanted to give it a try.

## Kepler/K2 mission

<center>
![image](/img/exoplanet-analysis/k2_graphic.jpeg)
*Image Credit: NASA Ames/W. Stenzel*
</center>

Kepler is a **space observatory** launched by NASA in March 2009 to **discover Earth-size planets orbiting other stars**. The loss of a second of the four reaction wheels during May 2013 put an end to the original mission. Fortunately, scientists decided to create an **entirely community-driven mission** called K2, to **reuse the Kepler spacecraft and its assets**. But furthermore, the community is also encouraged to exploit the mission's unique data archive **because everything is opendata**. Every image taken by the satellite can be **downloaded and analyzed by anyone**.

More informations about the telescope itself can be found **[here](https://keplerscience.arc.nasa.gov/the-kepler-space-telescope.html)**.

## Where I'm going

The goal of my project is to see if **I can contribute to the exoplanets search** using new tools such as **[Warp10](https://pierrez.github.io/blog/engage-maximum-warp-speed-in-time-series-analysis-with-warpscript/)** and **[TensorFlow](https://tensorflow.org)**. As I'm currently following **[Andrew Ng courses about Deep Learning](https://www.coursera.org/learn/neural-networks-deep-learning)**, it is a great opportunity to play with Tensorflow in a personal project. The project can be divided into several steps:

* **Import** the data
* **Dive** into the dataset
* **Analyze** the data using WarpScript
* **Build** a neural network to search for exoplanets

## Step 1: Acquire data and push it to Warp10

As stated previously, data are available from the The Mikulski Archive for Space Telescopes or [MAST](https://archive.stsci.edu/). It's a **NASA funded project** to support and provide to the astronomical community a variety of astronomical data archives. Both Kepler and K2 dataset are available through **campaigns**. Each campaign has a collection of tar files, which are containing the FITS files associated. A **[FITS](https://en.wikipedia.org/wiki/FITS)** file is an **open format** for images which is also **containing scientific data**. 

<center>
![image](/img/exoplanet-analysis/fits.png)
*FITS file representation. [Image Credit: KEPLER & K2 Science Center](https://keplerscience.arc.nasa.gov/k2-observing.html)*
</center>

To speed-up acquisition, I developed **[kepler-lens](https://github.com/PierreZ/kepler-lens)** to **download Kepler/K2 dataset and extract the needed time series automatically** into a CSV format. Then **[Kepler2Warp10](https://github.com/PierreZ/kepler2warp10)** is used to **push the CSV files generated by kepler-lens to Warp10**. Kepler-lens is using two awesomes libraries:

* **[pyKe](https://github.com/KeplerGO/PyKE)** to export the data from the **[FITS](https://en.wikipedia.org/wiki/FITS)** files to CSV (**[#PR69](https://github.com/KeplerGO/PyKE/pull/76)** and **[#PR76](https://github.com/KeplerGO/PyKE/pull/76)**)

* **[kplr](kplr)** is used to tag the dataset. For example, I will be able to set a label for every exoplanet found.

<center>
{{< tweet 906843673698213888 >}}
</center>

The whole importation took a whole week, for:

* **400k distincts time series**
* **1.5 TB** of data

The Warp10 instance is **self-hosted** on a dedicated **[Kimsufi](https://www.kimsufi.com)** server in OVH. Here's the full specifications for the curious one:

<center>
![image](/img/exoplanet-analysis/kimsufi.png)
</center>

# Step 2: Dive into the dataset

![image](/img/exoplanet-analysis/diving.gif)

The dataset is composed of two types of series:

* kepler.sap The SAP light curve is a **pixel summation time-series** of all calibrated flux falling within the optimal aperture
* kepler.sap.flux.err is the **uncertainty data** coupled to kepler.sap

Each series has differents labels:

* the **id** of the star
* the **catalog** used for the id, which is **[KIC](https://archive.stsci.edu/kepler/kic.html)** for Kepler, and **[EPIC](https://archive.stsci.edu/k2/epic/search.php)** for K2.

And some series can have attributes(which are like labels but dynamic, ie not parted of the row-key in the storage layer):

* **koi** which is the number of objects of interests for this star
* **training-set** is a label used to ease research for confirmed exoplanets, mostly to easily find useful GTS for the training-set
* the rest of the attributes will be in the following format: the id of the **object of interest** as the key and the **disposition** in value which is the **category of this KOI** from the Exoplanet Archive. Current values are **CANDIDATE, FALSE POSITIVE, NOT DISPOSITIONED or CONFIRMED**.

Let's plot the data! For this example, I'm going to take a **special case**: Tabby’s Star. KIC 8462852 is a **star about ~1400 light years** from Earth which has exhibited some **strange characteristics** while being monitored by the Kepler space telescope. Specifically a series of dimming events which **can not be perfectly explained by existing theories**. **One possible exciting option is the presence of an alien mega-structure**. For the most comprehensive information please read the **[original scientific paper](http://arxiv.org/pdf/1509.03622v1.pdf)**. This star has his own **[SubReddit](https://www.reddit.com/r/KIC8462852/)**!

# Step 3: Analysis using WarpScript

![image](/img/engage-maximum-distorsion-warp10/warpscript.png)

For those who don't know WarpScript, I recommend reading my previous blogpost "**[Engage maximum warp speed in time series analysis with WarpScript](https://pierrez.github.io/blog/engage-maximum-warp-speed-in-time-series-analysis-with-warpscript/)**"