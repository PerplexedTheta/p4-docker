#!/usr/bin/env bash

if [[ ! -d "/opt/p4d" ]]; then
    echo -ne "[ERR]\t/opt/p4d not found - please mount a volume here"
    exit 1
fi

if [[ "${EULA}" != "true" ]]; then
    echo "================================================================================"
    echo "=                                    STOP!                                     ="
    echo "=                                                                              ="
    echo "= This software is subject to the Perforce T&Cs, and the P4 supplimental T&Cs. ="
    echo "= Please visit the following URLs and read the T&Cs in full.                   ="
    echo "=                                                                              ="
    echo "= #1: https://www.perforce.com/system/files/2026-03/2026.03.24%20Perforce%20Master%20Terms%20and%20Conditions.pdf
    echo "= #2: https://www.perforce.com/system/files/2026-02/2026.02.26%20Perforce%20P4%20Supplemental%20Terms.pdf
    echo "=                                                                              ="
    echo "= Once you are satisfied, please pass EULA=true as an environment variable to  ="
    echo "= surpress this message.                                                       ="
    echo "=                                                                              ="
    echo "================================================================================"
    exit 1
fi

if [[ ! -d "/opt/p4d/ssl" ]]; then
    mkdir -p /opt/p4d/ssl
    echo -ne "[INFO]\tCreating new SSL certificates\n"
    openssl req -new -newkey rsa:2048 \
        -days 3650 -nodes -x509 \
        -keyout /opt/p4d/ssl/privatekey.txt \
        -out /opt/p4d/ssl/certificate.txt || exit 1 
fi

if [[ ! -f "/opt/p4d/.p4config" ]]; then
    echo -ne "[INFO]\tCreating new .p4enviro file\n"
    touch /opt/p4d/.p4config || exit 1
fi
if [[ ! -f "/opt/p4d/.p4enviro" ]]; then
    echo -ne "[INFO]\tCreating new .p4enviro file\n"
    cp /var/lib/p4/p4enviro.sample.txt /opt/p4d/.p4enviro || exit 1
fi
if [[ -f "/opt/p4d/.p4sh" ]]; then
    echo -ne "[INFO]\tSourcing .p4sh\n"
    . /opt/p4d/.p4sh || exit 1
fi

if [[ -z "$P4ROOT" ]]; then
    echo -ne "[ERR]\tP4ROOT unset - please set it"
    exit 1
fi
if [[ -z "$P4PORT" ]]; then
    echo -ne "[ERR]\tP4PORT unset - please set it"
    exit 1
fi
if [[ -z "$P4LOG" ]]; then
    echo -ne "[ERR]\tP4LOG unset - please set it"
    exit 1
fi
if [[ -z "$P4JOURNAL" ]]; then
    echo -ne "[ERR]\tP4JOURNAL unset - please set it"
    exit 1
fi

exec /var/lib/p4/p4d -r $P4ROOT -p $P4PORT -L $P4LOG -J $P4JOURNAL
