require 'json'
require 'open-uri'

module Echonest
  class Analysis
    CHROMATIC = %w(C C# D D# E F F# G G# A A# B).freeze
    
    def initialize(json)
      @body = JSON.parse(json)
    end

    def self.new_from_url(url)
      new(open(url).read)
    end
    
    def tempo
      track_info['tempo']
    end

    def duration
      track_info['duration']
    end

    def end_of_fade_in
      track_info['end_of_fade_in']
    end

    def key
      track_info['key']
    end
    
    # Returns the corresponding letter for the key number value.
    def key_letter
      CHROMATIC[key]
    end

    def loudness
      track_info['loudness']
    end

    def mode
      track_info['mode']
    end
    
    def minor?
      mode == 0
    end

    def major?
      !minor?
    end

    def start_of_fade_out
      track_info['start_of_fade_out']
    end

    def time_signature
      track_info['time_signature']
    end

    def bars
      @body['bars'].map do |bar|
        Bar.new(bar['start'], bar['duration'], bar['confidence'])
      end
    end

    def beats
      @body['beats'].map do |beat|
        Beat.new(beat['start'], beat['duration'], beat['confidence'])
      end
    end

    def sections
      @body['sections'].map do |section|
        Section.new(section['start'], section['duration'], section['confidence'])
      end
    end

    def tatums
      @body['tatums'].map do |tatum|
        Tatum.new(tatum['start'], tatum['duration'], tatum['confidence'])
      end
    end

    def segments
      @body['segments'].map do |segment|
        loudness = Loudness.new(0.0, segment['loudness_start'])
        max_loudness = Loudness.new(segment['loudness_max_time'], segment['loudness_max'])

        Segment.new(
          segment['start'],
          segment['duration'],
          segment['confidence'],
          loudness,
          max_loudness,
          segment['pitches'],
          segment['timbre']
          )
      end
    end

    def track_info
      @body['track']
    end
  end
end
