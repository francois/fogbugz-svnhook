module FogbugzSvnhook
  class Parser
    %%{
      machine commit_message_parser;

      action mark { mark = p }
      action bugid { bugid = data[mark .. p] }
      action name { name = data[mark .. p] }

      action close { action = :close }
      action fix { action = :fix }
      action reference { action = :reference }
      action reopen { action = :reopen }
      action reactivate { action = :reactivate }
      action implement { action = :implement }
      action assign { action = :assign }
      action notify { listener.send(action, bugid.pack("C*")) }
      action notify_assign { listener.send(action, name.pack("C*")) }

      bugid = ("#" ('1'..'9')>mark ('0'..'9')**)@bugid %notify;
      bugid_separator = (space* (punct | /and/i) space*);
      bugids = (bugid (bugid_separator bugid)*);

      plainname = (alpha+) >mark %name;
      dqname = ('"' (alpha (alpha | space)*) >mark %name '"');
      sqname = ("'" (alpha (alpha | space)*) >mark %name "'");
      name = (sqname | dqname | plainname);

      close = (/close/i /s/i? /:/?) %close;
      fix = (/fix/i /es/i? /:/?) %fix;
      reference = (/reference/i /s/i? /:/?) %reference;
      reopen = (/re/i? /open/i /s/i? /:/?) %reopen;
      reactivate = (/re/i? /activate/i /s/i? /:/?) %reactivate;
      implement = (/implement/i (/ed/i | /s/i)? /:/?) %implement;

      assign = (/re/i? /assign/i (/s/i | /ed/i)? (space+ /to/i)? /:/?) %assign;
      assignto = (assign name) %notify_assign;

      keywords = (close | fix | reference | implement | reopen | reactivate | assignto);
      text = (any - (keywords | bugids));
      main := (text* (keywords space* bugids)*);
    }%%

    %%write data;

    class << self
      def parse(msg, listener)
        data = msg.unpack("C*")
        eof = data.length

        bugid, action, name = nil

        %%write init;
        %%write exec;
      end
    end
  end
end
