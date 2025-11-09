#!/bin/bash
#
# This script runs acceptance tests for the project. It uses tesseract to perform OCR
# on a set of test images and compares the output against expected results.
#
# Usage: ./acceptance.sh

set -e

# Tesseract must be installed for this script to work.
if ! which tesseract >/dev/null; then
	echo "Tesseract OCR is not installed. Please install it to run acceptance tests."
	exit 1
fi

# Prepare temporary directory for screenshots
rm -rf .tmp/screenshots
mkdir -p .tmp/screenshots

# Function to capture a screenshot of the entire screen, good for debugging
function capture_screen() {
	local output_file=$1
	screencapture -x "$output_file"
}

# Function to capture a screenshot of the menubar area, this make OCR more reliable and efficient
function capture_menubar() {
	local output_file=$1
	screencapture -R0,0,1000,30 -x "$output_file"
}

# Function to determine if the menubar is visible using OCR
function is_menubar_visible() {
	local ocr_output
	ocr_output=$(tesseract "$1" - --psm 6 2>/dev/null)
	echo "$ocr_output" | grep -iq "finder\|file\|edit\|view"
}

function toggle_menubar() {
	hs -c "spoon.ToggleMenubar:toggle()"
	if [ $? -ne 0 ]; then
		echo "Failed to toggle menubar visibility via Hammerspoon."
		exit 1
	fi
	sleep 2
}

echo "Running acceptance tests..."

echo "Capturing initial menubar state..."
capture_screen .tmp/screenshots/initial-debug.png 
capture_menubar .tmp/screenshots/initial.png

is_menubar_visible .tmp/screenshots/initial.png \
	&& initial_state="visible" \
	|| initial_state="hidden"

echo "Initial menubar state is: $initial_state"

echo "Toggling menubar visibility..."
toggle_menubar

capture_screen .tmp/screenshots/after-toggle-debug.png
capture_menubar .tmp/screenshots/after-toggle.png

is_menubar_visible .tmp/screenshots/after-toggle.png \
	&& after_toggle_state="visible" \
	|| after_toggle_state="hidden"

echo "Menubar state after toggle is: $after_toggle_state"

if [ "$initial_state" = "$after_toggle_state" ]; then
	echo "Menubar state did not change after toggle. Test failed."
	exit 1
fi

echo "Toggling menubar visibility back to initial state..."
toggle_menubar

capture_screen .tmp/screenshots/menubar-shown-again-debug.png
capture_menubar .tmp/screenshots/menubar-shown-again.png

is_menubar_visible .tmp/screenshots/menubar-shown-again.png \
	&& final_state="visible" \
	|| final_state="hidden"

echo "Menubar state after second toggle is: $final_state"

if [ "$initial_state" != "$final_state" ]; then
	echo "Menubar state did not revert back after second toggle. Test failed."
	exit 1
fi

echo "Acceptance tests passed."
