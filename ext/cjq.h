#ifndef __CJQ_H__
#define __CJQ_H__

#include <string.h>
#include <errno.h>

#include <jq.h>
#include <ruby.h>

struct jq_container {
  jq_state *jq;
  int closed;
};

#endif //__CJQ_H__
