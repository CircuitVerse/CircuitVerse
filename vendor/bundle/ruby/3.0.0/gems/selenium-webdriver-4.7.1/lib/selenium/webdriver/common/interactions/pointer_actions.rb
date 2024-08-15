# frozen_string_literal: true

# Licensed to the Software Freedom Conservancy (SFC) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The SFC licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

module Selenium
  module WebDriver
    module PointerActions
      attr_writer :default_move_duration

      #
      # By default this is set to 250ms in the ActionBuilder constructor
      # It can be overridden with default_move_duration=
      #

      def default_move_duration
        @default_move_duration ||= @duration / 1000.0 # convert ms to seconds
      end

      #
      # Presses (without releasing) at the current location of the PointerInput device. This is equivalent to:
      #
      #   driver.action.click_and_hold(nil)
      #
      # @example Clicking and holding at the current location
      #
      #    driver.action.pointer_down(:left).perform
      #
      # @param [Selenium::WebDriver::Interactions::PointerPress::BUTTONS] button the button to press.
      # @param [Symbol || String] device optional name of the PointerInput device with the button
      #   that will be pressed
      # @return [ActionBuilder] A self reference.
      #

      def pointer_down(button = :left, device: nil, **opts)
        button_action(button, :create_pointer_down, device: device, **opts)
      end

      #
      # Releases the pressed mouse button at the current mouse location of the PointerInput device.
      #
      # @example Releasing a button after clicking and holding
      #
      #    driver.action.pointer_down(:left).pointer_up(:left).perform
      #
      # @param [Selenium::WebDriver::Interactions::PointerPress::BUTTONS] button the button to release.
      # @param [Symbol || String] device optional name of the PointerInput device with the button that will
      #   be released
      # @return [ActionBuilder] A self reference.
      #

      def pointer_up(button = :left, device: nil, **opts)
        button_action(button, :create_pointer_up, device: device, **opts)
      end

      #
      # Moves the pointer to the in-view center point of the given element.
      # Then the pointer is moved to optional offset coordinates.
      #
      # The element is not scrolled into view.
      # MoveTargetOutOfBoundsError will be raised if element with offset is outside the viewport
      #
      # When using offsets, both coordinates need to be passed.
      #
      # @example Move the pointer to element
      #
      #   el = driver.find_element(id: "some_id")
      #   driver.action.move_to(el).perform
      #
      # @example
      #
      #   el = driver.find_element(id: "some_id")
      #   driver.action.move_to(el, 100, 100).perform
      #
      # @param [Selenium::WebDriver::Element] element to move to.
      # @param [Integer] right_by Optional offset from the in-view center of the
      #   element. A negative value means coordinates to the left of the center.
      # @param [Integer] down_by Optional offset from the in-view center of the
      #   element. A negative value means coordinates to the top of the center.
      # @param [Symbol || String] device optional name of the PointerInput device to move.
      # @return [ActionBuilder] A self reference.
      #

      def move_to(element, right_by = nil, down_by = nil, device: nil, duration: default_move_duration, **opts)
        pointer = pointer_input(device)
        pointer.create_pointer_move(duration: duration,
                                    x: right_by || 0,
                                    y: down_by || 0,
                                    origin: element,
                                    **opts)
        tick(pointer)
        self
      end

      #
      # Moves the pointer from its current position by the given offset.
      #
      # The viewport is not scrolled if the coordinates provided are outside the viewport.
      # MoveTargetOutOfBoundsError will be raised if the offsets are outside the viewport
      #
      # @example Move the pointer to a certain offset from its current position
      #
      #    driver.action.move_by(100, 100).perform
      #
      # @param [Integer] right_by horizontal offset. A negative value means moving the pointer left.
      # @param [Integer] down_by vertical offset. A negative value means moving the pointer up.
      # @param [Symbol || String] device optional name of the PointerInput device to move
      # @return [ActionBuilder] A self reference.
      # @raise [MoveTargetOutOfBoundsError] if the provided offset is outside the document's boundaries.
      #

      def move_by(right_by, down_by, device: nil, duration: default_move_duration, **opts)
        pointer = pointer_input(device)
        pointer.create_pointer_move(duration: duration,
                                    x: Integer(right_by),
                                    y: Integer(down_by),
                                    origin: Interactions::PointerMove::POINTER,
                                    **opts)
        tick(pointer)
        self
      end

      #
      # Moves the pointer to a given location in the viewport.
      #
      # The viewport is not scrolled if the coordinates provided are outside the viewport.
      # MoveTargetOutOfBoundsError will be raised if the offsets are outside the viewport
      #
      # @example Move the pointer to a certain position in the viewport
      #
      #    driver.action.move_to_location(100, 100).perform
      #
      # @param [Integer] x horizontal position. Equivalent to a css 'left' value.
      # @param [Integer] y vertical position. Equivalent to a css 'top' value.
      # @param [Symbol || String] device optional name of the PointerInput device to move
      # @return [ActionBuilder] A self reference.
      # @raise [MoveTargetOutOfBoundsError] if the provided x or y value is outside the document's boundaries.
      #

      def move_to_location(x, y, device: nil, duration: default_move_duration, **opts)
        pointer = pointer_input(device)
        pointer.create_pointer_move(duration: duration,
                                    x: Integer(x),
                                    y: Integer(y),
                                    origin: Interactions::PointerMove::VIEWPORT,
                                    **opts)
        tick(pointer)
        self
      end

      #
      # Clicks (without releasing) in the middle of the given element. This is
      # equivalent to:
      #
      #   driver.action.move_to(element).click_and_hold
      #
      # @example Clicking and holding on some element
      #
      #    el = driver.find_element(id: "some_id")
      #    driver.action.click_and_hold(el).perform
      #
      # @param [Selenium::WebDriver::Element] element the element to move to and click.
      # @param [Symbol || String] device optional name of the PointerInput device to click with
      # @return [ActionBuilder] A self reference.
      #

      def click_and_hold(element = nil, button: nil, device: nil)
        move_to(element, device: device) if element
        pointer_down(button || :left, device: device)
        self
      end

      #
      # Releases the depressed left mouse button at the current mouse location.
      #
      # @example Releasing an element after clicking and holding it
      #
      #    el = driver.find_element(id: "some_id")
      #    driver.action.click_and_hold(el).release.perform
      #
      # @param [Symbol || String] device optional name of the PointerInput device with the button
      #   that will be released
      # @return [ActionBuilder] A self reference.
      #

      def release(button: nil, device: nil)
        pointer_up(button || :left, device: device)
        self
      end

      #
      # Clicks in the middle of the given element. Equivalent to:
      #
      #   driver.action.move_to(element).click
      #
      # When no element is passed, the current mouse position will be clicked.
      #
      # @example Clicking on an element
      #
      #    el = driver.find_element(id: "some_id")
      #    driver.action.click(el).perform
      #
      # @example Clicking at the current mouse position
      #
      #    driver.action.click.perform
      #
      # @param [Selenium::WebDriver::Element] element An optional element to click.
      # @param [Symbol || String] device optional name of the PointerInput device with the button
      #   that will be clicked
      # @return [ActionBuilder] A self reference.
      #

      def click(element = nil, button: nil, device: nil)
        move_to(element, device: device) if element
        pointer_down(button || :left, device: device)
        pointer_up(button || :left, device: device)
        self
      end

      #
      # Performs a double-click at middle of the given element. Equivalent to:
      #
      #   driver.action.move_to(element).double_click
      #
      # When no element is passed, the current mouse position will be double-clicked.
      #
      # @example Double-click an element
      #
      #    el = driver.find_element(id: "some_id")
      #    driver.action.double_click(el).perform
      #
      # @example Double-clicking at the current mouse position
      #
      #    driver.action.double_click.perform
      #
      # @param [Selenium::WebDriver::Element] element An optional element to move to.
      # @param [Symbol || String] device optional name of the PointerInput device with the button
      #   that will be double-clicked
      # @return [ActionBuilder] A self reference.
      #

      def double_click(element = nil, device: nil)
        move_to(element, device: device) if element
        click(device: device)
        click(device: device)
        self
      end

      #
      # Performs a context-click at middle of the given element. First performs
      # a move_to to the location of the element.
      #
      # When no element is passed, the current mouse position will be context-clicked.
      #
      # @example Context-click at middle of given element
      #
      #   el = driver.find_element(id: "some_id")
      #   driver.action.context_click(el).perform
      #
      # @example Context-clicking at the current mouse position
      #
      #    driver.action.context_click.perform
      #
      # @param [Selenium::WebDriver::Element] element An element to context click.
      # @param [Symbol || String] device optional name of the PointerInput device with the button
      #   that will be context-clicked
      # @return [ActionBuilder] A self reference.
      #

      def context_click(element = nil, device: nil)
        click(element, button: :right, device: device)
      end

      #
      # A convenience method that performs click-and-hold at the location of the
      # source element, moves to the location of the target element, then
      # releases the mouse.
      #
      # @example Drag and drop one element onto another
      #
      #   el1 = driver.find_element(id: "some_id1")
      #   el2 = driver.find_element(id: "some_id2")
      #   driver.action.drag_and_drop(el1, el2).perform
      #
      # @param [Selenium::WebDriver::Element] source element to emulate button down at.
      # @param [Selenium::WebDriver::Element] target element to move to and release the
      #   mouse at.
      # @param [Symbol || String] device optional name of the PointerInput device with the button
      #   that will perform the drag and drop
      # @return [ActionBuilder] A self reference.
      #

      def drag_and_drop(source, target, device: nil)
        click_and_hold(source, device: device)
        move_to(target, device: device)
        release(device: device)
        self
      end

      #
      # A convenience method that performs click-and-hold at the location of
      # the source element, moves by a given offset, then releases the mouse.
      #
      # @example Drag and drop an element by offset
      #
      #   el = driver.find_element(id: "some_id1")
      #   driver.action.drag_and_drop_by(el, 100, 100).perform
      #
      # @param [Selenium::WebDriver::Element] source Element to emulate button down at.
      # @param [Integer] right_by horizontal move offset.
      # @param [Integer] down_by vertical move offset.
      # @param [Symbol || String] device optional name of the PointerInput device with the button
      #   that will perform the drag and drop
      # @return [ActionBuilder] A self reference.
      #

      def drag_and_drop_by(source, right_by, down_by, device: nil)
        click_and_hold(source, device: device)
        move_by(right_by, down_by, device: device)
        release(device: device)
        self
      end

      private

      def button_action(button, action, device: nil, **opts)
        pointer = pointer_input(device)
        pointer.send(action, button, **opts)
        tick(pointer)
        self
      end

      def pointer_input(name = nil)
        device(name: name, type: Interactions::POINTER) || add_pointer_input(:mouse, 'mouse')
      end
    end # PointerActions
  end # WebDriver
end # Selenium
