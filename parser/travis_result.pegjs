Result
  = (Noise command:Command Noise { return command; })+

Noise
  = (!Command .)*

Command
  = TimeStart commandBody:CommandBody TimeEnd {
    return commandBody;
  }

CommandBody
  = chars:(!TimeEnd char:. {return char})* {
    return chars.join('').replace(/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]/g, '').replace(/\r\n/g, "\n")
  }

TimeStart
  = "travis_time:start:" (!"\n" .)+ "\n"

TimeEnd
  = "travis_time:end:" (!"\n" .)+ "\n"
