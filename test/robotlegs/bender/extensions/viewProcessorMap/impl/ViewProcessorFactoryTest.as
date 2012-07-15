//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.viewProcessorMap.impl
{
	import flash.display.Sprite;
	import org.flexunit.assertThat;
	import org.hamcrest.core.allOf;
	import org.hamcrest.collection.array;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.isTrue;
	import org.swiftsuspenders.Injector;
	import flash.display.Shape;
	import robotlegs.bender.extensions.viewProcessorMap.support.TrackingProcessor;
	import robotlegs.bender.extensions.matching.TypeMatcher;
	import flash.events.IEventDispatcher;
	import robotlegs.bender.extensions.viewProcessorMap.support.ITrackingProcessor;
	import robotlegs.bender.extensions.viewProcessorMap.api.ViewProcessorMapError;

	public class ViewProcessorFactoryTest
	{
		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var viewProcessorFactory:ViewProcessorFactory;
		private var trackingProcessor:TrackingProcessor;
		private var injector:Injector;
		private var view:Sprite;
		/*============================================================================*/
		/* Test Setup and Teardown                                                    */
		/*============================================================================*/

		[Before]
		public function before():void
		{
			injector = new Injector();
			viewProcessorFactory = new ViewProcessorFactory(injector);
			trackingProcessor = new TrackingProcessor();
			view = new Sprite();
		}

		/*============================================================================*/
		/* Tests                                                                      */
		/*============================================================================*/
		
		[Test]
		public function runProcessOnExistingProcessor():void
		{
			const mappings:Array = [];
			mappings.push( new ViewProcessorMapping(new TypeMatcher().allOf(Sprite).createTypeFilter(), trackingProcessor));
						
			viewProcessorFactory.runProcessors(view, Sprite, mappings);
			assertThat(trackingProcessor.processedViews, array([view]));
		}
		
		[Test]
		public function runProcessOnMultipleProcessors():void
		{
			const mappings:Array = [];
			mappings.push( new ViewProcessorMapping(new TypeMatcher().allOf(Sprite).createTypeFilter(), trackingProcessor));
			
			const trackingProcessor2:TrackingProcessor = new TrackingProcessor();
			mappings.push( new ViewProcessorMapping(new TypeMatcher().allOf(Sprite).createTypeFilter(), trackingProcessor2));
			
			viewProcessorFactory.runProcessors(view, Sprite, mappings);
			assertThat( trackingProcessor.processedViews, array([view]) );
			assertThat( trackingProcessor2.processedViews, array([view]) );
		}
		
		[Test]
		public function getsProcessorFromInjectorWhereMapped():void
		{
			const mappings:Array = [];
			mappings.push( new ViewProcessorMapping(new TypeMatcher().allOf(Sprite).createTypeFilter(), TrackingProcessor));
			
			injector.map(TrackingProcessor).toValue(trackingProcessor);
						
			viewProcessorFactory.runProcessors(view, Sprite, mappings);
			assertThat( trackingProcessor.processedViews, array([view]) );	
		}
		
		[Test]
		public function createsProcessorSingletonMappingWhereNotMappedAndRunsProcess():void
		{
			const mappings:Array = [];
			mappings.push( new ViewProcessorMapping(new TypeMatcher().allOf(Sprite).createTypeFilter(), TrackingProcessor));
						
			viewProcessorFactory.runProcessors(view, Sprite, mappings);
			const createdTrackingProcessor:TrackingProcessor = injector.getInstance(TrackingProcessor);
			assertThat( createdTrackingProcessor.processedViews, array([view]) );				
		}
		
		[Test]
		public function createsProcessorSingletonMappingWhereNotMapped():void
		{
			const mappings:Array = [];
			mappings.push( new ViewProcessorMapping(new TypeMatcher().allOf(Sprite).createTypeFilter(), TrackingProcessor));
						
			viewProcessorFactory.runProcessors(view, Sprite, mappings);
			assertThat( injector.satisfiesDirectly(TrackingProcessor), isTrue() );				
		}
		
		[Test(expects='robotlegs.bender.extensions.viewProcessorMap.api.ViewProcessorMapError')]
		public function requestingAnUnmappedInterfaceThrowsInformativeError():void
		{
			const mappings:Array = [];
			mappings.push( new ViewProcessorMapping(new TypeMatcher().allOf(Sprite).createTypeFilter(), ITrackingProcessor));

			viewProcessorFactory.runProcessors(view, Sprite, mappings);
		}
		
	}
}