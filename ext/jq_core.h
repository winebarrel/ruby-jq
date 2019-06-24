#ifndef __JQ_CORE_H__
#define __JQ_CORE_H__

#include <string.h>
#include <errno.h>

#include <jq.h>
#include <ruby.h>

struct jq_container {
  jq_state *jq;
  struct jv_parser *parser;
  int closed;
  VALUE errmsg;
};

#endif //__JQ_CORE_H__
