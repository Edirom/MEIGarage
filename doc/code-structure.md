# MEIGarage and TEIGarage code structure

## About

This code based on [OxGarage](https://github.com/TEIC/oxgarage) and modularized to allow for easier maintenance and creating Garages for different usage scenarios.

[TEIGarage](https://github.com/TEIC/TEIGarage) bundles functionality for the [TEI format](https://tei-c.org/), while [MEIGarage](https://github.com/Edirom/MEIGarage) focusses on the [MEI format](https://music-encoding.org/).

The code is structured in a base and various plugins (currently following the [Java Plugin Framework](http://jpf.sourceforge.net/)). All parts are available as GitHub Maven Packages to be used as dependencies.

# How does the XGarage work

The program is divided into different parts: main project, API, framework, plug-ins (validators, converters, customizations) and web client. 

<img src="https://anneferger.github.io/MEITEIGarage/TEIMEC23/images/structure.png" alt="Overview of code structure" width="500">

## Main projects

The main projects decide which plugins are included by specifiying them as dependencies in the pom.xml.
They include a servlet using the servlethelper in the framework, that uses the framework to perform conversions. It is REST-full and you can control it simply using POST and GET request. First you need to send GET request asking for all the possible input formats. Then you need to send another GET request to get all possible output formats from a given input format. After this, you need to POST your file into a given URL and that's it. This can be particularly useful for batch processing a large number of files. For more information see https://teigarage.tei-c.de/ege-webservice/ or https://meigarage.edirom.de/ege-webservice/. Of course, if you already know the URL for the conversion, it is enough to POST your file to this URL without having to go through all these steps.

* [TEIGarage](https://github.com/TEIC/TEIGarage) - [![GitHub release](https://img.shields.io/github/v/release/TEIC/TEIGarage.svg)](https://github.com/TEIC/TEIGarage/releases) - [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.11516696.svg)](https://doi.org/10.5281/zenodo.11516696)
* [MEIGarage](https://github.com/Edirom/MEIGarage) - [![GitHub release](https://img.shields.io/github/v/release/Edirom/MEIGarage.svg)](https://github.com/Edirom/MEIGarage/releases) - [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.8199808.svg)](https://doi.org/10.5281/zenodo.8199808)
  
## Basis

API offers only the base, on which the framework is built. The role of the framework is to search for all provided plug-ins, initialize them and calculate all possible input types and conversion paths. To do this, it asks each converter to provide a list of all conversions it is able to do. Then the framework constructs a graph, where different document types are nodes and conversions are edges. This graph is directed and weighted. Weights to the edges are assigned based on a subjective judgement of how good or bad the resulting document looks. The better the document looks, the lower the weight. These weights are then summed together and only the path with minimal total weight is offered to the user in case there are several routes available from input format to output format. Framework also provides for processing the path of conversions that are needed to be done and performing the necessary conversions in a chain of threads, where one thread passes its result to the next thread until the desired output format is reached. Each thread does exactly one conversion and uses a converter to perform it.

* [ege-api](https://github.com/TEIC/ege-api) - [![GitHub release](https://img.shields.io/github/v/release/TEIC/ege-api.svg)](https://github.com/TEIC/ege-api/releases) - [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10419333.svg)](https://doi.org/10.5281/zenodo.10419333)
* [ege-framework](https://github.com/TEIC/ege-framework) - [![GitHub release](https://img.shields.io/github/v/release/TEIC/ege-framework.svg)](https://github.com/TEIC/ege-framework/releases) - [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10419432.svg)](https://doi.org/10.5281/zenodo.10419432)

## Available Plugins

The role of validator is to validate documents before conversions. This is done in order to stop user from transforming a malformed document, as this could cause an error during conversion, or an unexpected result. 

Then there are converters, which do the conversion from one format to another. Each converter must be able to provide a list of all possible conversions it can do and also perform a conversion. 

Contained in TEIGarage:

* [ege-validator](https://github.com/TEIC/ege-validator) - [![GitHub release](https://img.shields.io/github/v/release/TEIC/ege-validator.svg)](https://github.com/TEIC/ege-validator/releases) [![Maven Action](https://github.com/TEIC/ege-validator/actions/workflows/maven.yml/badge.svg)](https://github.com/TEIC/ege-validator/actions/workflows/maven.yml)
* [ege-xsl-converter](https://github.com/TEIC/ege-xsl-converter) - [![GitHub release](https://img.shields.io/github/v/release/TEIC/ege-xsl-converter.svg)](https://github.com/TEIC/ege-xsl-converter/releases)  [![Maven Action](https://github.com/TEIC/ege-xsl-converter/actions/workflows/maven.yml/badge.svg)](https://github.com/TEIC/ege-xsl-converter/actions/workflows/maven.yml) XslConverter and TEIConverter are using xsl style-sheets to convert between different form of XML documents.
* [tei-converter](https://github.com/TEIC/tei-converter) - [![GitHub release](https://img.shields.io/github/v/release/TEIC/tei-converter.svg)](https://github.com/TEIC/tei-converter/releases) [![Maven Action](https://github.com/TEIC/tei-converter/actions/workflows/maven.yml/badge.svg)](https://github.com/TEIC/tei-converter/actions/workflows/maven.yml) The main difference between them is that TEIConverter is used for a more complex conversions, e.g. conversions to and from docx and odt.
* [oo-converter](https://github.com/TEIC/oo-converter) - [![GitHub release](https://img.shields.io/github/v/release/TEIC/oo-converter.svg)](https://github.com/TEIC/oo-converter/releases)  [![Maven Action](https://github.com/TEIC/oo-converter/actions/workflows/maven.yml/badge.svg)](https://github.com/TEIC/oo-converter/actions/workflows/maven.yml) The OOConverter is using a JODConverter library to start OpenOffice.org in a headless mode and then calls it to convert a document.
* [tei-javalib](https://github.com/TEIC/tei-javalib) - [![GitHub release](https://img.shields.io/github/v/release/TEIC/tei-javalib.svg)](https://github.com/TEIC/tei-javalib/releases)

Contained in MEIGarage:

* [lilypond-converter](https://github.com/Edirom/lilypond-converter) - [![GitHub release](https://img.shields.io/github/v/release/Edirom/lilypond-converter.svg)](https://github.com/Edirom/lilypond-converter/releases) [![Maven Action](https://github.com/Edirom/lilypond-converter/actions/workflows/maven.yml/badge.svg)](https://github.com/Edirom/lilypond-converter/actions/workflows/maven.yml)
* [mei-customization](https://github.com/Edirom/mei-customization) - [![GitHub release](https://img.shields.io/github/v/release/Edirom/mei-customization.svg)](https://github.com/Edirom/mei-customization/releases)  [![Maven Action](https://github.com/Edirom/mei-customization/actions/workflows/maven.yml/badge.svg)](https://github.com/Edirom/mei-customization/actions/workflows/maven.yml)
* [mei-validator](https://github.com/Edirom/mei-validator) - [![GitHub release](https://img.shields.io/github/v/release/Edirom/mei-validator.svg)](https://github.com/Edirom/mei-validator/releases) [![Maven Action](https://github.com/Edirom/mei-validator/actions/workflows/maven.yml/badge.svg)](https://github.com/Edirom/mei-validator/actions/workflows/maven.yml)
* [mei-xsl-converter](https://github.com/Edirom/mei-xsl-converter) - [![GitHub release](https://img.shields.io/github/v/release/Edirom/mei-xsl-converter.svg)](https://github.com/Edirom/mei-xsl-converter/releases)  [![Maven Action](https://github.com/Edirom/mei-xsl-converter/actions/workflows/maven.yml/badge.svg)](https://github.com/Edirom/mei-xsl-converter/actions/workflows/maven.yml)
* [verovio-converter](https://github.com/Edirom/verovio-converter) - [![GitHub release](https://img.shields.io/github/v/release/Edirom/verovio-converter.svg)](https://github.com/Edirom/verovio-converter/releases)  [![Maven Action](https://github.com/Edirom/verovio-converter/actions/workflows/maven.yml/badge.svg)](https://github.com/Edirom/verovio-converter/actions/workflows/maven.yml)
* [meico-converter](https://github.com/Edirom/meico-converter) - [![GitHub release](https://img.shields.io/github/v/release/Edirom/meico-converter.svg)](https://github.com/Edirom/meico-converter/releases)  [![Maven Action](https://github.com/Edirom/meico-converter/actions/workflows/maven.yml/badge.svg)](https://github.com/Edirom/meico-converter/actions/workflows/maven.yml)

## Graphical User Interfaces (GUIs)

The last important part of OxGarage is the web client. This is basically a user interface for the web service. The important thing about it is that it requires JavaScript to work. This web client simply sends GET and POST requests to web service and processes the responses.

* [ege-webclient](https://github.com/TEIC/ege-webclient): basic web GUI currently used by the TEIGarage.  - [![GitHub release](https://img.shields.io/github/v/release/TEIC/ege-webclient.svg)](https://github.com/TEIC/ege-webclient/releases) [![Version](https://img.shields.io/github/v/release/TEIC/ege-webclient.svg)](https://github.com/TEIC/ege-webclient/releases/latest) [![Maven Action](https://github.com/TEIC/ege-webclient/actions/workflows/maven.yml/badge.svg)](https://github.com/TEIC/ege-webclient/actions/workflows/maven.yml)
* [ViFE web client for MEIGarage](https://github.com/Edirom/vife-meigarage-webclient): customized web GUI for MEIGarage.  - [![GitHub release](https://img.shields.io/github/v/release/Edirom/vife-meigarage-webclient.svg)](https://github.com/Edirom/vife-meigarage-webclient/releases)


# How to add new conversions

Adding new conversions can be done in two different ways. You can either build a new converter, or add new conversions into existing converters. Adding new conversions is rather different in each converter and you can find very brief instructions in the next sections. After you have added the format, you will also need to add new mime-type and extension pair into fileExt.xml file in the web service directory. It is strongly advised to use the same format description, format name and format mime-type for one document format, in case it is defined in several converters.

## Adding new plugins
Currently the garages work with converter, customization and validation plugins. To add a new conversion or validation a new java maven project needs to be created and used as a dependency in the main configuration project (currently [MEIGarage](https://github.com/Edirom/MEIGarage) or [TEIGarage](https://github.com/TEIC/TEIGarage), see above). The new project needs to include:

### plugin.xml

src/main/resources/META-INF/plugin.xml
```
<?xml version="1.0" ?>
<!DOCTYPE plugin PUBLIC "-//JPF//Java Plug-in Manifest 0.4" "http://jpf.sourceforge.net/plugin_0_7.dtd">
<plugin id="meico-converter" version="0.1">
    <requires>
        <import plugin-id="pl.psnc.dl.ege.root"/>
    </requires>
    <extension plugin-id="pl.psnc.dl.ege.root" point-id="Converter" id="MeicoConverter">
        <parameter id="class" value="de.edirom.meigarage.meico.MeicoConverter"/>
        <parameter id="name" value="Meico Converter"/>
    </extension>
</plugin>
```

### Class implementing the converter class pl.psnc.dl.ege.component.Converter

`public class FooConverter implements Converter,ErrorHandler`

## Adding new conversions to XslConverter

This can be done very easily. All you have to do is to add the new style-sheets into you stylesheets directory. Then you need to provide a plugin.xml file specifying some properties of the conversion. For and example of such file, see profiles/default/csv folder in your stylesheets directory. After it is done, you only need to refresh the web client page and new conversion should appear. Note that you can also add new conversions by defining them in the ege-xsl-converter/src/main/resources/META-INF/plugin.xml file. But then you have to recompile the whole application.

## Adding new conversions to TEIConverter

This is a bit more difficult. First you need to add the conversion information into Format.java file. After this is done, you need to define the conversion in the TEIconverter.java file. You might also need to look into ConverterConfiguration.java in order to change some conversion settings. When everything is finished, you need to rebuild and redeploy the whole application.

## Adding new conversions to OOConverter

In order to do this, you need to add the document format into one of the files: InputTextFormat.java, InputSpreadsheetFormat.java, InputPresentationFormat.java, OutputTextFormat.java, OutputSpreadsheetFormat.java, OutputPresentationFormat.java. Then you need to change some of the Java files depending on the support of the new format by the JODConverter library.

# How to redefine weights of edges for conversions

As was mentioned before, each conversion is assigned a weight according to how much we trust the result. The better the result, the lower the weight. This has to be done, because there is a huge amount of possible ways how to get from input format to output format. Therefore, now the program chooses always the path with the smallest total weight, which is calculated as sum of weights of all conversions which form the path. If there is more than one path with the smallest total weight, one of the paths is chosen non-deterministically.

However, during time the conversions will surely become more refined and produce better results. Therefore, you might want to change the weights to make the service use the current best conversions more often. Again, what you need to do in order to change the weights depends quite a lot on the converter.

## Changing weights in XslConverter

To change the weights in XslConverter you need to change the value of “cost” parameter in plugin.xml file. This file can be found in ege-xsl-converter/src/main/resources/META-INF directory. If the conversion you are looking for is not there, it is possible that it was added by definition in stylesheets directory. In that case, you need to find the appropriate plugin.xml file in your stylesheets directory.

## Changing weights in TEIConverter

In this case you need to find Format.java file. There you can easily adjust the weights.

## Changing weights in OOConverter

In OOConverter weights are calculated as the sum of the input's and output's weight. Therefore, if for example in the new version of OpenOffice.org its ability to read docx files improves rapidly and you would like to reflect this in the weightings, you need to find the appropriate input type in the appropriate file. In this case it would be DOCX in InputTextFormat.java. Now you simply change the value of the cost variable and it's done.
