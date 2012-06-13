/* The Intel P to C/Pillar Compiler */
/* COPYRIGHT_NOTICE_1 */

/* place holders for now */
I_ rts_getThreadId (W_ tid)
{
    return (I_)tid;
}

I_ cmp_thread (W_ tidA, W_ tidB)
{
    if (tidA > tidB) return 1;
    else if (tidA < tidB) return -1;
    else return 0;
}

I_ rtsSupportsBoundThreads()
{
    return 0;
}

/*** IO Manager Stuff ***/

#if defined (__MINGW32__) || defined(WIN32)
HANDLE getIOManagerEvent()
{
    /* XXX NG: this is for a non-threaded runtime. */
    return NULL;
}

W_ readIOManagerEvent()
{
    /* XXX NG: this is for a non-threaded runtime. */
    return 0;
}

void sendIOManagerEvent(W_ e)
{
    /* XXX NG: this is for a non-threaded runtime. */
}
#endif
