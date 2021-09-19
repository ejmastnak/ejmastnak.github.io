---
layout: github
---
# Convolutional Neural Networks and Particle Physics
I made this project in the scope of *Seminar* course requirements at the Faculty of Math and Physics at the University of Ljubljana---see [About the Seminar course at FMF](#about-the-seminar-course-at-fmf) below for context. The project explores the use of convolutional neural networks for classifying the products of high-energy collisions produced in particle physics experiments like the Large Hadron Collider at CERN.

You might be interested in...
- [reading the PDF paper]({% link seminar/paper.pdf %}) (there is also an associated slide show presentation in [English]({% link seminar/presentation.pdf %}) or [Slovene]({% link seminar/presentation.pdf %}))
- or [browsing the GitHub repo](https://github.com/ejmastnak/fmf-seminar)  containing the project's source files

## About the project
The project explores the use of convolutional neural networks for classifying the products of high-energy particle collisions using low-level, image-based detector data. Particle classification means identifying the results of a collision, often as simply as with a binary yes/no answer, e.g. "this collision produced a Higgs boson" or "this collision did not produce a Higgs boson". Performing classification with a high degree of certainty is vital if, say, you a research group interested in announcing the discovery of a new elementary particle.

This project is distinguished by the focus on performing classification using as raw, low-level data as possible (i.e. the data directly produced by a particle detector's trackers and calorimeters, without further processing). Classification techniques that produce results directly from low-level data are called "end-to-end" classifiers. End-to-end classifiers are interesting because:
- they eliminate complicated preprocessing steps, and
- they provide a beautifully general, broadly applicable framework, since a wide range of classification problems share the same type of raw data. This means a scientist could use the same class of algorithms to solve a wide variety of problems.

Raw detector data takes the form of image-like snapshots of the energy and position of particles traveling through a particle detector. Image-like data is best processed using a class of machine learning systems called convolutional neural networks, which is how CNNs get involved in the project.

#### Summary
The [paper]({% link seminar/paper.pdf %}) and presentations follow the progression below:
- present the problem of particle classification
- describe the physical quantities comprising low-level collision data and explain the physical principles behind a modern particle detector's measurement instruments (using the Compact Muon Solenoid at the LHC as an example)
- as a foundation for convolutional neural networks, explain the basic principles of fully-connected networks
- explain the basis working principles of convolutional neural networks
- as concrete example of CNN-based end-to-end classification, summarize the results of the 2020 paper [*End-to-End Physics Event Classification with CMS Open Data*](https://link.springer.com/article/10.1007/s41781-020-00038-8) by M. Andrews, M. Paulini, S. Gleyzer, and B. Poczos in the Journal **Computing and Software for Big Science**.



## About the Seminar course at FMF
*Seminar* is a required course for students in the final semester of the undergraduate physics program at the Faculty of Mathematics and Physics at the University of Ljubljana. In the scope of the course, students, under the guidance of a faculty mentor, write an undergraduate thesis on a currently relevant physics topic and present the topic to their classmates. 

The project encompasses two parts:

- a written paper (no more than about 20 pages)
- a roughly 35 to 40-minute slide-show presentation to the student's classmates, course coordinator, and mentor, followed by questions from the audience and a seminar-style discussion of the topic.

The project is intended primarily as an exercise in clear scientific writing and presentation, a training of sorts for giving presentations at scientific conferences. However, students are not expected (nor encouraged) to produce original research in the scope of the *Seminar* course, simply to clearly present their chosen topic at a level suitable (i.e. not too advanced) for a general final-year undergraduate audience.

