#!/usr/bin/env python
# -*- coding: utf-8 -*-

import re, codecs
from os import path, unlink
from xml.sax import saxutils
from datetime import date
from HTMLParser import HTMLParser

class SubtitleParser():
    filename = None
    subtitles = None

    def parse(self, filename):
        if not path.exists(filename):
            raise ValueError('The file "%s" does not exist.' % filename)
        self.filename = filename
        self.subtitles = []

        matches = self.__parse_file()
        for match in matches:
            subtitle = self.__create_subtitle(match)
            if subtitle:
                parser = CustomParser()
                parser.feed(subtitle['text'])
                subtitle['text'] = parser.render_output();
                self.subtitles.append(subtitle)

        return self.subtitles

    def export(self, filename, language):
        fp = codecs.open(filename, 'w', 'utf-8')
        fp.write(u'<?xml version="1.0" encoding="UTF-8"?>\n')
        fp.write(u'<tt xml:lang="%s" xmlns="http://www.w3.org/ns/ttml">\n' % language)
        fp.write(u'  <head>\n')
        fp.write(u'    <metadata xmlns:ttm="http://www.w3.org/ns/ttml#metadata">\n')
        fp.write(u'      <ttm:copyright>Telemundo (c) %s, all rights reserved.</ttm:copyright>\n' % date.today().year)
        fp.write(u'    </metadata>\n')
        fp.write(u'  </head>\n')
        fp.write(u'  <body>\n')
        fp.write(u'    <div>\n')
        for subtitle in self.subtitles:
            line = u'      <p xml:id="caption-%d" begin="%s" end="%s">%s</p>\n' % (subtitle['pos'], subtitle['begin'], subtitle['end'], subtitle['text'])
            fp.write(line)
        fp.write(u'    </div>\n')
        fp.write(u'  </body>\n')
        fp.write(u'</tt>\n')
        fp.close()

    def __parse_file(self):
        lines = codecs.open(self.filename, 'r', 'utf-8').read().encode('utf-8')

        return re.findall(r'(?P<data>.*?)\r?\n\r?\n', lines, re.MULTILINE + re.DOTALL)

    def __create_subtitle(self, caption):
        lines = caption.splitlines()
        position = int(lines.pop(0))
        timecodes = map(lambda x: x.replace(',', '.'), lines.pop(0).split(' --> '))
        text = u'%s' % u'\n'.join([line.decode('utf-8') for line in lines])

        return {
            'pos': position,
            'begin': timecodes[0],
            'end': timecodes[1],
            'text': text
        }

class CustomParser(HTMLParser):
    stack = None

    def __init__(self):
        self.stack = []
        self.reset()

    def handle_data(self, data):
        self.stack.append(data)

    def render_output(self):
        return unicode(u''.join(self.stack))
