#!/bin/bash

sudo bash -c "cat > /etc/sudoers.d/$USER" << EOF
$USER ALL=(ALL) NOPASSWD:ALL
EOF