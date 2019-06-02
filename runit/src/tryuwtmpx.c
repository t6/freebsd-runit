#include <sys/types.h>
#include <utmpx.h>

struct utmpx ut;

int main(void) {
  char *s =ut.ut_user;
  return(0);
}
