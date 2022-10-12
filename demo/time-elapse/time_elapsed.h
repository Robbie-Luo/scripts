#ifndef TIME_ELAPLSED_H_
#define TIME_ELAPLSED_H_


#define TEST_TIME_ELAPSED  0 



#ifdef TEST_TIME_ELAPSED
#include <sys/time.h>
#include <time.h>
#include <string.h>
#include "uthash.h"


#define TIME_ELAPSED_MAX_RECORDS_PER_NAME   5


typedef struct   {
    const char* name;
    unsigned int sample_freq;
    unsigned int frames;
    unsigned int total_frames;
    unsigned int max_frame;
    unsigned int min_frame;    
    unsigned int current;
    unsigned int print_enable;
    unsigned long time_elapsed;
    unsigned long time_elapsed_max;
    unsigned long time_elapsed_min;
    unsigned long time_elapsed_avg[TIME_ELAPSED_MAX_RECORDS_PER_NAME];
    struct timeval tv1;
    struct timeval tv2; 
    UT_hash_handle hh;
}T_TIME_ELAPSED_RECORD;

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-variable"

static T_TIME_ELAPSED_RECORD *t_records_head = NULL;
static unsigned int totalRecords = 0;

#pragma GCC diagnostic pop

//////////////////////////////////// For time elapsed record 

#define TIME_ELAPSED_ADD_RECORD(X, freq) \
    do { \
        T_TIME_ELAPSED_RECORD *new_rec = NULL; \
        HASH_FIND_STR(t_records_head, #X, new_rec); \
        if (!new_rec) { \
            int i; \
            new_rec = (T_TIME_ELAPSED_RECORD *)malloc(sizeof(T_TIME_ELAPSED_RECORD)); \
            new_rec->name = #X; \
            new_rec->sample_freq = freq; \
            new_rec->total_frames = 0; \
            new_rec->max_frame = 0; \
            new_rec->min_frame = 0; \
            new_rec->current = 0; \
            new_rec->print_enable = 0; \
            new_rec->time_elapsed = 0; \
            new_rec->time_elapsed_max = 0; \
            new_rec->time_elapsed_min = 0; \
            for (i = 0; i < TIME_ELAPSED_MAX_RECORDS_PER_NAME; i++) \
                new_rec->time_elapsed_avg[i] = 0; \
            HASH_ADD_STR(t_records_head, name, new_rec);\
            printf("add time elapsed record (%d) success: <%s>, sample frequency = %d\n", totalRecords++, new_rec->name, freq); \
            }\
       } while(0)


#define TIME_ELAPSED_GET_BEFORE(X) \
    do { \
        T_TIME_ELAPSED_RECORD *find = NULL; \
        HASH_FIND_STR(t_records_head, #X, find);\
        if (find) { \
            gettimeofday(&find->tv1, 0); \
        } else { \
            printf("time elapsed get time after failed: %s\n", #X); \
        } \
    } while(0)


#define TIME_ELAPSED_GET_AFTER(X) \
    do { \
        T_TIME_ELAPSED_RECORD *find = NULL; \
        HASH_FIND_STR(t_records_head, #X, find);\
        if (find) {\
            unsigned long time_interval = 0; \
            \
            gettimeofday(&find->tv2, 0); \
            time_interval = 1000000 * (find->tv2.tv_sec - find->tv1.tv_sec) + (find->tv2.tv_usec - find->tv1.tv_usec); \
            find->time_elapsed += time_interval; \
            \
            if (find->time_elapsed_max < time_interval) {\
                 find->time_elapsed_max = time_interval; \
                 find->max_frame = find->total_frames; \
            } \
            if (find->time_elapsed_min > time_interval || find->time_elapsed_min == 0) {\
                find->time_elapsed_min = time_interval;  \
                find->min_frame = find->total_frames; \
            } \
            if (find->frames > find->sample_freq) {  \
                find->time_elapsed_avg[find->current] = find->time_elapsed / find->frames; \
                find->current = (find->current + 1) % TIME_ELAPSED_MAX_RECORDS_PER_NAME; \
                find->time_elapsed = find->frames = 0; \
                find->print_enable = 1; \
            } \
            \
            find->frames++; \
            find->total_frames++; \
        } else { \
            printf ("time elapsed get time after failed: %s\n", #X); \
        } \
    } while(0)  


#define TIME_ELAPSED_PRT(X) \
do { \
    T_TIME_ELAPSED_RECORD *find = NULL; \
    HASH_FIND_STR(t_records_head, #X, find);\
    if (find && find->print_enable) {\
        unsigned long time_elapsed_avg = 0; \
        int j = 0; \
        int miss = 0; \
        find->print_enable = 0; \
        \
        for (; j < TIME_ELAPSED_MAX_RECORDS_PER_NAME; j++) \
            time_elapsed_avg += (find->time_elapsed_avg[j] == 0 ? miss++, 0 : find->time_elapsed_avg[j]); \
        \
        printf("[avg: %.3f(ms), max: %.3f(ms) at frame %d , min: %.3f(ms) at frame %d] elapsed for <%s>, sample frequency = %d\n", \
            (double)time_elapsed_avg / (TIME_ELAPSED_MAX_RECORDS_PER_NAME - miss) / 1000, \
            (double)find->time_elapsed_max / 1000, find->max_frame, \
            (double)find->time_elapsed_min / 1000, find->min_frame, #X, find->sample_freq); \
    } \
} while(0)  


//////////////////////////////////// For time elapsed print on-the-fly


#define TIME_ELAPSED_OTF_DEF_VAR(X) \
        static unsigned int frames_##X = 0; \
        static unsigned long t_##X = 0; \
        struct timeval tv1_##X, tv2_##X;


#define TIME_ELAPSED_OTF_GET_BEFORE(X) \
    do { \
        gettimeofday(&tv1_##X, 0); \
    } while(0) 


#define TIME_ELAPSED_OTF_GET_AFTER(X) \
    do { \
        gettimeofday(&tv2_##X, 0); \
        t_##X += 1000000 * (tv2_##X.tv_sec - tv1_##X.tv_sec) + (tv2_##X.tv_usec - tv1_##X.tv_usec); \
        frames_##X++; \
     } while(0)


#define TIME_ELAPSED_OTF_PRT(X, threshold) \
    do { \
        if (frames_##X > threshold) {  \
            printf("[%.3f(ms)] elapsed for %s, frame threshold = %s\n", (double)t_##X / frames_##X / 1000, #X, #threshold);  \
            t_##X = frames_##X = 0; \
        } \
     } while(0)


//////////////////////////////////// For time elapsed print others
#define TIME_ELAPSED_BUILD \
    do { \
        static int build_disp = 0; \
        \
        if (build_disp == 0) { \
            printf("new_rec build at: %s %s\n", __DATE__, __TIME__); \
            build_disp = 1; \
           } \
    } while(0)  

#else


#define TIME_ELAPSED_ADD_RECORD(X, freq)
#define TIME_ELAPSED_GET_BEFORE(X)
#define TIME_ELAPSED_GET_AFTER(X)
#define TIME_ELAPSED_PRT(X)
#define TIME_ELAPSED_OTF_DEF_VAR(X)
#define TIME_ELAPSED_OTF_GET_BEFORE(X)
#define TIME_ELAPSED_OTF_GET_AFTER(X)
#define TIME_ELAPSED_OTF_PRT(X, threshold)
#define TIME_ELAPSED_BUILD
#endif

#endif  //TIME_ELAPLSED_H_

